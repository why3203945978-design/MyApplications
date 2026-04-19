import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { LostItem, ItemType, ItemStatus, User } from '../model/DataModel';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';

@Entry
@Component
struct DetailPage {
  @State item: LostItem | null = null;
  @State currentUser: User | null = null;
  @State isLoading: boolean = true;
  private prefUtil: PreferencesUtil | null = null;

  async aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params.item) {
      this.item = JSON.parse(params.item);
    }
    
    // 获取当前用户信息
    this.prefUtil = await PreferencesUtil.getInstance(getContext(this));
    if (this.prefUtil) {
      const userInfoStr = await this.prefUtil.getString('userInfo', '');
      if (userInfoStr) {
        this.currentUser = JSON.parse(userInfoStr);
      }
    }
    this.isLoading = false;
  }

  getTypeText(): string {
    if (!this.item) return '';
    return this.item.type === ItemType.LOST ? '失物' : '招领';
  }

  getTypeColor(): string {
    if (!this.item) return '#999999';
    return this.item.type === ItemType.LOST ? '#FF6B6B' : '#4ECDC4';
  }

  getStatusText(): string {
    if (!this.item) return '';
    switch (this.item.status) {
      case ItemStatus.LOST: return '寻找中';
      case ItemStatus.FOUND: return '待认领';
      case ItemStatus.CLAIMED: return '已认领';
      case ItemStatus.RETURNED: return '已归还';
      default: return '未知';
    }
  }

  getStatusColor(): string {
    switch (this.item?.status) {
      case ItemStatus.LOST: return '#FF9800';
      case ItemStatus.FOUND: return '#4CAF50';
      case ItemStatus.CLAIMED: return '#9E9E9E';
      case ItemStatus.RETURNED: return '#2196F3';
      default: return '#999999';
    }
  }

  contactPublisher() {
    if (!this.item) return;
    promptAction.showToast({
      message: `联系方式: ${this.item.contact}`,
      duration: 3000
    });
  }

  canMarkAsComplete(): boolean {
    if (!this.item || !this.currentUser) return false;
    // 检查是否是发布者
    return this.item.publisherId === this.currentUser.id;
  }

  async markAsComplete() {
    if (!this.item || !this.prefUtil) return;
    
    try {
      const itemListKey = this.item.type === ItemType.LOST ? 'lostItems' : 'foundItems';
      const items = await this.prefUtil.getArray<LostItem>(itemListKey, []);
      const index = items.findIndex((i: LostItem) => i.id === this.item?.id);
      if (index !== -1) {
        items.splice(index, 1);
        await this.prefUtil.putArray(itemListKey, items);
      }
      
      this.item.status = this.item.type === ItemType.LOST ? ItemStatus.RETURNED : ItemStatus.CLAIMED;
      const completedItems = await this.prefUtil.getArray<LostItem>('completedItems', []);
      completedItems.unshift(this.item);
      if (completedItems.length > 15) {
        completedItems.splice(15);
      }
      await this.prefUtil.putArray('completedItems', completedItems);
      
      promptAction.showToast({ message: '已标记为完成' });
      setTimeout(() => {
        router.replace({ url: 'pages/HomePage' });
      }, 1000);
    } catch (error) {
      console.error('标记完成失败:', error);
      promptAction.showToast({ message: '操作失败，请稍后重试' });
    }
  }

  formatDate(date: Date): string {
    const d = new Date(date);
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
  }
  build() {
    Column() {
      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .color('#007AFF')
          .margin({ top: 200 })
      } else if (!this.item) {
        this.buildErrorPage()
      } else {
        this.buildDetailPage()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildErrorPage() {
    Column() {
      Text('❌')
        .fontSize(80)
      Text('加载失败')
        .fontSize(18)
        .fontColor('#999999')
        .margin({ top: 20 })
      Button('返回')
        .margin({ top: 30 })
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildDetailPage() {
    Column() {
      Row() {
        Button('←')
          .fontSize(24)
          .backgroundColor('transparent')
          .onClick(() => router.back())

        Text('详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          Row() {
            Text(this.getTypeText())
              .fontSize(14)
              .fontColor('#FFFFFF')
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .borderRadius(12)
              .backgroundColor(this.getTypeColor())

            Text(this.getStatusText())
              .fontSize(14)
              .fontColor('#FFFFFF')
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .borderRadius(12)
              .backgroundColor(this.getStatusColor())
              .margin({ left: 12 })
          }
          .width('100%')
          .margin({ top: 16 })
          Text(this.item ? this.item.title : '')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .margin({ top: 20 })

          Row() {
            Column() {
              Text('发布者')
                .fontSize(12)
                .fontColor('#999999')
              Text(this.item ? this.item.publisherName : '')
                .fontSize(16)
                .fontColor('#333333')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            Column() {
              Text('发布时间')
                .fontSize(12)
                .fontColor('#999999')
              Text(this.item ? this.formatDate(this.item.createdAt) : '')
                .fontSize(14)
                .fontColor('#333333')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.End)
          }
          .width('100%')
          .margin({ top: 20 })
          .padding(16)
          .backgroundColor('#F8F8F8')
          .borderRadius(12)
          if (this.item) {
            this.infoRow('📍 地点', this.item.location)
            this.infoRow('📞 联系方式', this.item.contact)
            if (this.item.category) {
              this.infoRow('📂 分类', this.item.category)
            }
          }

          Column() {
            Text('📝 详细描述')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 8 })
            Text(this.item ? this.item.description : '')
              .fontSize(14)
              .fontColor('#666666')
              .lineHeight(20)
          }
          .width('100%')
          .margin({ top: 20 })
          .padding(16)
          .backgroundColor('#F8F8F8')
          .borderRadius(12)

          Button('📱 联系发布者')
            .width('90%')
            .height(50)
            .backgroundColor('#007AFF')
            .borderRadius(25)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 30, bottom: 10 })
            .onClick(() => this.contactPublisher())

          // 标记完成按钮，只对发布者显示
          if (this.canMarkAsComplete() && this.item && (this.item.status === ItemStatus.LOST || this.item.status === ItemStatus.FOUND)) {
            Button(this.item.type === ItemType.LOST ? '✅ 失主已找回物品' : '✅ 物品已归还失主')
              .width('90%')
              .height(50)
              .backgroundColor('#4CAF50')
              .borderRadius(25)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 30 })
              .onClick(() => this.markAsComplete())
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  infoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .width(100)

      Text(value)
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({
      width: { bottom: 1 },
      color: '#F0F0F0'
    })
  }
}