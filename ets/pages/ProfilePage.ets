import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';
import { User, LostItem, ItemType, ItemStatus, Message } from '../model/DataModel';

@Entry
@Component
struct ProfilePage {
  @State userInfo: User | null = null;
  @State myItems: LostItem[] = [];
  @State myMessages: Message[] = [];
  @State selectedTab: number = 0;
  @State isLoading: boolean = true;
  private prefUtil: PreferencesUtil | null = null;
  async aboutToAppear() {
    this.prefUtil = await PreferencesUtil.getInstance(getContext(this));
    if (this.prefUtil) {
      await this.loadUserInfo();
      await this.loadMyItems();
      await this.loadMyMessages();
    }
    this.isLoading = false;
  }

  async onPageShow() {
    if (this.prefUtil) {
      await this.loadUserInfo();
      await this.loadMyItems();
      await this.loadMyMessages();
    }
  }
  async loadUserInfo() {
    if (!this.prefUtil) return;
    const userInfoStr = await this.prefUtil.getString('userInfo', '');
    if (userInfoStr) {
      const loadedUser: User = JSON.parse(userInfoStr) as User;
      this.userInfo = {
        id: loadedUser.id,
        username: loadedUser.username,
        avatar: loadedUser.avatar,
        phone: loadedUser.phone,
        email: loadedUser.email,
        schoolId: loadedUser.schoolId,
        backgroundColor: loadedUser.backgroundColor || '#FFFFFF'
      };
    } else {
      this.userInfo = {
        id: '1',
        username: '张三',
        avatar: '',
        phone: '13800138000',
        email: 'zhangsan@school.edu',
        schoolId: '20240001',
        backgroundColor: '#FFFFFF'
      };
    }
  }

  async loadMyItems() {
    if (this.prefUtil && this.userInfo) {
      const lostItems = await this.prefUtil.getArray<LostItem>('lostItems', []);
      const foundItems = await this.prefUtil.getArray<LostItem>('foundItems', []);
      const allItems = [...lostItems, ...foundItems];
      this.myItems = allItems.filter((item: LostItem) => item.publisherId === this.userInfo?.id);
    }
  }

  async loadMyMessages() {
    if (this.prefUtil) {
      this.myMessages = await this.prefUtil.getArray<Message>('userMessages', []);
    }
  }
  async handleLogout() {
    if (!this.prefUtil) return;
    await this.prefUtil.putBoolean('isLogin', false);
    await this.prefUtil.putString('userInfo', '');
    router.replace({ url: 'pages/LoginPage' });
    this.showToast('已退出登录');
  }

  showToast(message: string) {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  editProfile() {
    router.push({ url: 'pages/EditProfilePage' });
  }

  goToItemDetail(item: LostItem) {
    router.push({
      url: 'pages/DetailPage',
      params: { item: JSON.stringify(item) }
    });
  }

  markMessageRead(message: Message) {
    if (!message.isRead) {
      message.isRead = true;
      this.showToast('已标记为已读');
    }
  }

  async clearAllMessages() {
    if (this.prefUtil) {
      await this.prefUtil.putArray('userMessages', []);
      this.myMessages = [];
      this.showToast('已清除所有消息');
    }
  }

  getStatusText(status: ItemStatus): string {
    switch (status) {
      case ItemStatus.LOST: return '寻找中';
      case ItemStatus.FOUND: return '待认领';
      case ItemStatus.CLAIMED: return '已认领';
      case ItemStatus.RETURNED: return '已归还';
      default: return '未知';
    }
  }

  getStatusColor(status: ItemStatus): string {
    switch (status) {
      case ItemStatus.LOST: return '#FF6B6B';
      case ItemStatus.FOUND: return '#4ECDC4';
      case ItemStatus.CLAIMED: return '#95E77E';
      case ItemStatus.RETURNED: return '#A8E6CF';
      default: return '#999999';
    }
  }

  formatDate(date: Date): string {
    const d = new Date(date);
    const now = new Date();
    const diff = now.getTime() - d.getTime();
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (days === 0) return '今天';
    if (days === 1) return '昨天';
    if (days < 7) return `${days}天前`;
    return `${d.getMonth() + 1}月${d.getDate()}日`;
  }

  build() {
    Column() {
      Row() {
        Button('←')
          .fontSize(24)
          .backgroundColor('transparent')
          .onClick(() => router.back())

        Text('个人中心')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(40)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.userInfo?.backgroundColor || '#FFFFFF')

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#007AFF')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            Column() {
              Row() {
                if (this.userInfo?.avatar && this.userInfo.avatar.length > 0) {
                  Image(this.userInfo.avatar)
                    .width(100)
                    .height(100)
                    .borderRadius(50)
                    .objectFit(ImageFit.Cover)
                    .margin({ right: 20 })
                } else {
                  Text(this.userInfo?.username?.charAt(0) || '用')
                    .fontSize(40)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold)
                    .width(100)
                    .height(100)
                    .backgroundColor('#007AFF')
                    .borderRadius(50)
                    .textAlign(TextAlign.Center)
                    .margin({ right: 20 })
                }

                Column() {
                  Text(this.userInfo?.username || '用户名')
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                  Text(this.userInfo?.phone || '手机号')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ top: 4 })
                  Text(this.userInfo?.email || '邮箱')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ top: 2 })
                }
                .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 24 })

              Row() {
                Column() {
                  Text('我的发布')
                    .fontSize(14)
                    .fontColor('#666666')
                  Text(this.myItems.length.toString())
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Center)
                .layoutWeight(1)

                Column() {
                  Text('消息')
                    .fontSize(14)
                    .fontColor('#666666')
                  Text(this.myMessages.length.toString())
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Center)
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 16, bottom: 16 })
              .backgroundColor('#F8F9FA')
              .borderRadius(12)
              .margin({ bottom: 20 })

              Row() {
                Button('编辑资料')
                  .layoutWeight(1)
                  .height(48)
                  .backgroundColor('#007AFF')
                  .fontColor('#FFFFFF')
                  .borderRadius(24)
                  .margin({ right: 12 })
                  .onClick(() => this.editProfile())

                Button('退出登录')
                  .layoutWeight(1)
                  .height(48)
                  .backgroundColor('#F5F5F5')
                  .fontColor('#333333')
                  .borderRadius(24)
                  .margin({ left: 12 })
                  .onClick(() => this.handleLogout())
              }
              .width('100%')
            }
            .width('100%')
            .padding(24)
            .backgroundColor('#FFFFFF')
            .borderRadius(20)
            .margin({ bottom: 16 })
            .shadow({
              radius: 8,
              color: 'rgba(0, 0, 0, 0.1)',
              offsetX: 0,
              offsetY: 4
            })

            Row() {
              Text('我的发布')
                .fontSize(16)
                .fontWeight(this.selectedTab === 0 ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.selectedTab === 0 ? '#007AFF' : '#666666')
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding(12)
                .onClick(() => this.selectedTab = 0)

              Divider()
                .vertical(true)
                .height(20)
                .color('#E0E0E0')

              Text('我的消息')
                .fontSize(16)
                .fontWeight(this.selectedTab === 1 ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.selectedTab === 1 ? '#007AFF' : '#666666')
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding(12)
                .onClick(() => this.selectedTab = 1)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 16 })

            if (this.selectedTab === 1) {
              Row() {
                Blank()
                Text('清除消息')
                  .fontSize(14)
                  .fontColor('#FF3B30')
                  .onClick(() => this.clearAllMessages())
              }
              .width('100%')
              .margin({ bottom: 12 })
            }

            if (this.selectedTab === 0) {
              if (this.myItems.length === 0) {
                Column() {
                  Text('📭')
                    .fontSize(80)
                    .margin({ top: 60 })
                  Text('暂无发布记录')
                    .fontSize(16)
                    .fontColor('#999999')
                    .margin({ top: 20 })
                  Button('去发布')
                    .width(120)
                    .height(40)
                    .backgroundColor('#007AFF')
                    .borderRadius(20)
                    .fontSize(14)
                    .margin({ top: 20 })
                    .onClick(() => {
                      router.push({ url: 'pages/PublishPage' });
                    })
                }
                .width('100%')
              } else {
                ForEach(this.myItems, (item: LostItem) => {
                  Column() {
                    Row() {
                      Column() {
                        Text(item.type === ItemType.LOST ? '📖 失物' : '🔍 招领')
                          .fontSize(12)
                          .fontColor('#FFFFFF')
                          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                          .borderRadius(8)
                          .backgroundColor(item.type === ItemType.LOST ? '#FF6B6B' : '#4ECDC4')
                      }

                      Blank()

                      Text(this.getStatusText(item.status))
                        .fontSize(12)
                        .fontColor(this.getStatusColor(item.status))
                    }
                    .width('100%')
                    .margin({ bottom: 8 })

                    Text(item.title)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                      .margin({ bottom: 8 })

                    Text(item.description)
                      .fontSize(14)
                      .fontColor('#666666')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .margin({ bottom: 12 })
                  .onClick(() => this.goToItemDetail(item))
                })
              }
            } else {
              if (this.myMessages.length === 0) {
                Column() {
                  Text('💬')
                    .fontSize(80)
                    .margin({ top: 60 })
                  Text('暂无消息')
                    .fontSize(16)
                    .fontColor('#999999')
                    .margin({ top: 20 })
                }
                .width('100%')
              } else {
                ForEach(this.myMessages, (message: Message) => {
                  Column() {
                    Row() {
                      Column() {
                        Text(message.title)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#333333')

                          Text(message.content)
                            .fontSize(14)
                            .fontColor('#666666')
                            .margin({ top: 4 })
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })

                          Text(this.formatDate(message.createdAt))
                            .fontSize(12)
                            .fontColor('#999999')
                            .margin({ top: 8 })
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)

                      if (!message.isRead) {
                        Column() {
                          Circle()
                            .width(8)
                            .height(8)
                            .fill('#FF6B6B')
                        }
                        .width(20)
                        .height(20)
                        .justifyContent(FlexAlign.Start)
                      }
                    }
                    .width('100%')
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .margin({ bottom: 12 })
                  .onClick(() => this.markMessageRead(message))
                })
              }
            }
          }
          .width('100%')
          .padding(16)
        }
        .scrollBar(BarState.Auto)
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.userInfo?.backgroundColor || '#FFFFFF')
  }
}