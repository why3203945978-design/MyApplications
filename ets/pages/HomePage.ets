import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { LostItem, ItemType, ItemStatus, User, Message } from '../model/DataModel';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';
import { LostItemCard } from '../components/LostItemCard';

interface BannerItem {
  id: number;
  image: Resource;
  title: string;
}

@Entry
@Component
struct HomePage {
  @State currentTab: number = 0;
  @State lostItems: LostItem[] = [];
  @State foundItems: LostItem[] = [];
  @State completedItems: LostItem[] = [];
  @State isLoading: boolean = true;
  @State currentBannerIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  private prefUtil: PreferencesUtil | null = null;
  
  private bannerData: Array<BannerItem> = [
    { id: 1, image: $r('app.media.image1'), title: '校园失物招领' },
    { id: 2, image: $r('app.media.image2'), title: '共建和谐校园' },
    { id: 3, image: $r('app.media.image3'), title: '失物信息早知道' }
  ];

  async aboutToAppear() {
    if (!HomePage.prefUtil) {
      HomePage.prefUtil = await PreferencesUtil.getInstance(getContext(this));
    }
    this.prefUtil = HomePage.prefUtil;
    this.loadData();
  }

  static prefUtil: PreferencesUtil | null = null;

  async clearCompletedItems() {
    if (this.prefUtil) {
      await this.prefUtil.putArray('completedItems', []);
      this.loadData();
      promptAction.showToast({ message: '已清理所有已完成记录' });
    }
  }

  async loadData() {
    console.info('HomePage: loadData called');
    this.isLoading = true;

    if (this.prefUtil) {
      const savedLostItems = await this.prefUtil.getArray<LostItem>('lostItems', []);
      const savedFoundItems = await this.prefUtil.getArray<LostItem>('foundItems', []);
      const savedCompletedItems = await this.prefUtil.getArray<LostItem>('completedItems', []);
      console.info('HomePage: Loaded lostItems count: ' + savedLostItems.length);
      console.info('HomePage: Loaded foundItems count: ' + savedFoundItems.length);

      this.lostItems = savedLostItems;
      this.foundItems = savedFoundItems;
      this.completedItems = savedCompletedItems;
    } else {
      console.warn('HomePage: prefUtil is null');
      this.lostItems = [];
      this.foundItems = [];
      this.completedItems = [];
    }

    this.isLoading = false;
  }

  goToPublish() {
    router.push({ url: 'pages/PublishPage' });
  }

  goToSearch() {
    router.push({ url: 'pages/SearchPage' });
  }

  goToProfile() {
    router.push({ url: 'pages/ProfilePage' });
  }

  goToDetail(item: LostItem) {
    router.push({
      url: 'pages/DetailPage',
      params: { item: JSON.stringify(item) }
    });
  }

  async addMessageToUser(userId: string, item: LostItem, messageType: string) {
    if (this.prefUtil) {
      const messages = await this.prefUtil.getArray<Message>('userMessages', []);
      let title = '';
      let content = '';
      if (messageType === 'returned') {
        if (item.type === ItemType.LOST) {
          title = '失主已找回物品';
          content = `您发布的"${item.title}"已被标记为已找回，失主已找回物品。`;
        } else {
          title = '物品已归还失主';
          content = `您发布的"${item.title}"已被标记为已认领，物品已归还失主。`;
        }
      } else if (messageType === 'claimed') {
        if (item.type === ItemType.LOST) {
          title = '失主已找回物品';
          content = `您发布的"${item.title}"已被标记为已找回，失主已找回物品。`;
        } else {
          title = '物品已归还失主';
          content = `您发布的"${item.title}"已被标记为已认领，物品已归还失主。`;
        }
      }
      const newMessage: Message = {
        id: Date.now().toString(),
        title: title,
        content: content,
        itemId: item.id,
        fromUserId: 'system',
        toUserId: item.publisherId,
        type: messageType,
        isRead: false,
        createdAt: new Date()
      };
      messages.unshift(newMessage);
      await this.prefUtil.putArray('userMessages', messages);
    }
  }

  async markAsReturned(item: LostItem) {
    if (this.prefUtil) {
      const itemListKey = item.type === ItemType.LOST ? 'lostItems' : 'foundItems';
      const items = await this.prefUtil.getArray<LostItem>(itemListKey, []);
      const index = items.findIndex((i: LostItem) => i.id === item.id);
      if (index !== -1) {
        items.splice(index, 1);
        await this.prefUtil.putArray(itemListKey, items);
      }
      item.status = ItemStatus.RETURNED;
      const completedItems = await this.prefUtil.getArray<LostItem>('completedItems', []);
      completedItems.unshift(item);
      if (completedItems.length > 15) {
        completedItems.splice(15);
      }
      await this.prefUtil.putArray('completedItems', completedItems);
      await this.addMessageToUser(item.publisherId, item, 'returned');
      this.loadData();
      promptAction.showToast({ message: '失主已找回物品' });
    }
  }

  async markAsClaimed(item: LostItem) {
    if (this.prefUtil) {
      const itemListKey = item.type === ItemType.LOST ? 'lostItems' : 'foundItems';
      const items = await this.prefUtil.getArray<LostItem>(itemListKey, []);
      const index = items.findIndex((i: LostItem) => i.id === item.id);
      if (index !== -1) {
        items.splice(index, 1);
        await this.prefUtil.putArray(itemListKey, items);
      }
      item.status = ItemStatus.CLAIMED;
      const completedItems = await this.prefUtil.getArray<LostItem>('completedItems', []);
      completedItems.unshift(item);
      if (completedItems.length > 15) {
        completedItems.splice(15);
      }
      await this.prefUtil.putArray('completedItems', completedItems);
      await this.addMessageToUser(item.publisherId, item, 'claimed');
      this.loadData();
      promptAction.showToast({ message: '物品已归还失主' });
    }
  }

  async syncToCompleted() {
    if (this.prefUtil) {
      let lostItems = await this.prefUtil.getArray<LostItem>('lostItems', []);
      let foundItems = await this.prefUtil.getArray<LostItem>('foundItems', []);
      let completedItems = await this.prefUtil.getArray<LostItem>('completedItems', []);
      const existingIds = new Set(completedItems.map((item: LostItem) => item.id));

      const newCompleted: LostItem[] = [];

      lostItems = lostItems.filter((item: LostItem) => {
        if (existingIds.has(item.id)) {
          return false;
        }
        if (item.status === ItemStatus.RETURNED) {
          newCompleted.push(item);
          return false;
        }
        return true;
      });

      foundItems = foundItems.filter((item: LostItem) => {
        if (existingIds.has(item.id)) {
          return false;
        }
        if (item.status === ItemStatus.CLAIMED) {
          newCompleted.push(item);
          return false;
        }
        return true;
      });

      completedItems = [...newCompleted, ...completedItems].slice(0, 15);

      await this.prefUtil.putArray('lostItems', lostItems);
      await this.prefUtil.putArray('foundItems', foundItems);
      await this.prefUtil.putArray('completedItems', completedItems);
      this.loadData();
      promptAction.showToast({ message: '同步完成，已移动' + newCompleted.length + '条记录' });
    }
  }
  // @Builder
  // TabBarBuilder(title: string, index: number) {
  //   Column() {
  //     Text(title)
  //       .fontSize(16)
  //       .fontColor(this.currentTab === index ? '#007AFF' : '#666666')
  //       .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
  //       .margin({ bottom: 8 })
  //     Divider()
  //       .height(2)
  //       .width('100%')
  //       .backgroundColor(this.currentTab === index ? '#007AFF' : 'transparent')
  //       .margin({ top: 0 })
  //   }
  //   .width('100%')
  //   .height('100%')
  //   .justifyContent(FlexAlign.Center)
  // }

  build() {
    Column() {
      Row() {
        Text('校园失物招领')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('🔍')
          .fontSize(24)
          .margin({ right: 20 })
          .onClick(() => this.goToSearch())

        Text('🔄')
          .fontSize(24)
          .margin({ right: 20 })
          .onClick(() => this.syncToCompleted())

        Text('➕')
          .fontSize(24)
          .margin({ right: 20 })
          .onClick(() => this.goToPublish())

        Text('👤')
          .fontSize(24)
          .onClick(() => this.goToProfile())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 10 })
      .backgroundColor('#FFFFFF')

      // 轮播图
      Swiper()
      {
        ForEach(this.bannerData, (item: BannerItem) => {
          Image(item.image)
            .width('100%')
            .height(200)
            .objectFit(3)
            .borderRadius(12)
        }, (item: BannerItem) => item.id.toString())
      }
      .width('100%')
      .height(200)
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .index(this.currentBannerIndex)
      .autoPlay(true)
      .interval(3000)
      .indicator(true)

      Row() {
        Column() {
          Text('失物信息')
            .fontSize(16)
            .fontColor(this.currentTab === 0 ? '#007AFF' : '#666666')
            .fontWeight(this.currentTab === 0 ? FontWeight.Medium : FontWeight.Normal)
            .margin({ bottom: 8 })
          Divider()
            .height(2)
            .width('100%')
            .backgroundColor(this.currentTab === 0 ? '#007AFF' : 'transparent')
            .margin({ top: 0 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 0;
          this.tabsController.changeIndex(0);
        })

        Column() {
          Text('招领信息')
            .fontSize(16)
            .fontColor(this.currentTab === 1 ? '#007AFF' : '#666666')
            .fontWeight(this.currentTab === 1 ? FontWeight.Medium : FontWeight.Normal)
            .margin({ bottom: 8 })
          Divider()
            .height(2)
            .width('100%')
            .backgroundColor(this.currentTab === 1 ? '#007AFF' : 'transparent')
            .margin({ top: 0 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 1;
          this.tabsController.changeIndex(1);
        })

        Column() {
          Text('已完成')
            .fontSize(16)
            .fontColor(this.currentTab === 2 ? '#007AFF' : '#666666')
            .fontWeight(this.currentTab === 2 ? FontWeight.Medium : FontWeight.Normal)
            .margin({ bottom: 8 })
          Divider()
            .height(2)
            .width('100%')
            .backgroundColor(this.currentTab === 2 ? '#007AFF' : 'transparent')
            .margin({ top: 0 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 2;
          this.tabsController.changeIndex(2);
        })
      }
      .width('100%')
      .height(50)
      .backgroundColor('#FFFFFF')

      Tabs({
        barPosition: BarPosition.Start,
        index: this.currentTab,
        controller: this.tabsController
      }) {
        TabContent() {
          if (this.isLoading) {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#007AFF')
              .margin({ top: 100 })
          } else if (this.lostItems.length === 0) {
            Column() {
              Text('📭')
                .fontSize(80)
                .margin({ top: 100 })
              Text('暂无失物信息')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 20 })
            }
            .width('100%')
          } else {
            List() {
              ForEach(this.lostItems, (item: LostItem) => {
                ListItem() {
                  LostItemCard({ item: item })
                    .onClick(() => this.goToDetail(item))
                }
              }, (item: LostItem) => item.id)
            }
            .width('100%')
            .height('100%')
            .padding({ left: 16, right: 16, top: 16 })
          }
        }
        .backgroundColor('#F5F5F5')

        TabContent() {
          if (this.isLoading) {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#007AFF')
              .margin({ top: 100 })
          } else if (this.foundItems.length === 0) {
            Column() {
              Text('📭')
                .fontSize(80)
                .margin({ top: 100 })
              Text('暂无招领信息')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 20 })
            }
            .width('100%')
          } else {
            List() {
              ForEach(this.foundItems, (item: LostItem) => {
                ListItem() {
                  LostItemCard({ item: item })
                    .onClick(() => this.goToDetail(item))
                }
              }, (item: LostItem) => item.id)
            }
            .width('100%')
            .height('100%')
            .padding({ left: 16, right: 16, top: 16 })
          }
        }
        .backgroundColor('#F5F5F5')

        TabContent() {
          if (this.isLoading) {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#007AFF')
              .margin({ top: 100 })
          } else if (this.completedItems.length === 0) {
            Column() {
              Text('📭')
                .fontSize(80)
                .margin({ top: 100 })
              Text('暂无已完成信息')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 20 })
            }
            .width('100%')
          } else {
            Column() {
              Row() {
                Text('共' + this.completedItems.length + '条记录')
                  .fontSize(14)
                  .fontColor('#666666')
                  .layoutWeight(1)
                Text('清理数据')
                  .fontSize(14)
                  .fontColor('#FF3B30')
                  .onClick(() => this.clearCompletedItems())
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })

              List() {
                ForEach(this.completedItems, (item: LostItem) => {
                  ListItem() {
                    LostItemCard({ item: item })
                      .onClick(() => this.goToDetail(item))
                  }
                }, (item: LostItem) => item.id)
              }
              .width('100%')
              .layoutWeight(1)
              .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .height('100%')
          }
        }
        .backgroundColor('#F5F5F5')
      }
      .width('100%')
      .layoutWeight(1)
      .barHeight(0)
      .onChange((index: number) => {
        this.currentTab = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}