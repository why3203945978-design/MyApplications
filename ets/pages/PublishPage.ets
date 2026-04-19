import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { LostItem, ItemType, ItemStatus, User } from '../model/DataModel';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';

const categories: string[] = ['证件', '电子产品', '包包', '衣物', '雨具', '学习用品', '生活用品', '其他'];

@CustomDialog
struct CategoryPickerDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: '' });
  @Link selectedCategory: string;

  build() {
    Column() {
      Text('选择分类')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .padding(16)

      Divider().color('#E5E5E5')

      List() {
        ForEach(categories, (cat: string) => {
          ListItem() {
            Row() {
              Text(cat)
                .fontSize(16)
                .fontColor(this.selectedCategory === cat ? '#007AFF' : '#333333')
                .layoutWeight(1)

              if (this.selectedCategory === cat) {
                Text('✓')
                  .fontSize(16)
                  .fontColor('#007AFF')
              }
            }
            .width('100%')
            .padding(16)
            .onClick(() => {
              this.selectedCategory = cat;
              this.controller.close();
            })
          }
        }, (cat: string) => cat)
      }
      .width('100%')
      .height(300)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
  }
}

@Entry
@Component
struct PublishPage {
  @State title: string = '';
  @State description: string = '';
  @State location: string = '';
  @State contact: string = '';
  @State selectedType: number = 0;
  @State category: string = '';
  @State isLoading: boolean = false;
  private prefUtil: PreferencesUtil | null = null;
  private categoryDialogController: CustomDialogController = new CustomDialogController({
    builder: CategoryPickerDialog({ selectedCategory: $category }),
    alignment: DialogAlignment.Bottom
  });

  async aboutToAppear() {
    this.prefUtil = await PreferencesUtil.getInstance(getContext(this));
  }

  async handlePublish() {
    if (!this.title || !this.description || !this.location || !this.contact) {
      this.showToast('请填写完整信息');
      return;
    }

    if (!this.contact.match(/^1[3-9]\d{9}$/) && !this.contact.includes('@')) {
      this.showToast('请输入正确的手机号或邮箱');
      return;
    }
    this.isLoading = true;
    if (this.prefUtil) {
      const userInfoStr = await this.prefUtil.getString('userInfo', '{}');
      const userInfo: User = JSON.parse(userInfoStr);
      const newItem: LostItem = {
        id: Date.now().toString(),
        title: this.title,
        description: this.description,
        type: this.selectedType === 0 ? ItemType.LOST : ItemType.FOUND,
        status: this.selectedType === 0 ? ItemStatus.LOST : ItemStatus.FOUND,
        location: this.location,
        time: new Date(),
        contact: this.contact,
        images: [],
        publisherId: userInfo.id || '1',
        publisherName: userInfo.username || '匿名',
        category: this.category || '其他',
        tags: [],
        createdAt: new Date()
      };
      
      const itemListKey = this.selectedType === 0 ? 'lostItems' : 'foundItems';
      const existingItems = await this.prefUtil.getArray<LostItem>(itemListKey, []);
      existingItems.unshift(newItem);
      await this.prefUtil.putArray(itemListKey, existingItems);
      const verifyItems = await this.prefUtil.getArray<LostItem>(itemListKey, []);
      console.info('PublishPage: Saved items count: ' + verifyItems.length);
      
      setTimeout(() => {
        this.showToast('发布成功');
        this.isLoading = false;
        router.replace({ url: 'pages/HomePage' });
      }, 500);
    }
  }

  showToast(message: string) {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  build() {
    Column() {
      Row() {
        Button('取消')
          .backgroundColor('transparent')
          .fontColor('#666666')
          .onClick(() => router.back())

        Text('发布信息')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button(this.isLoading ? '发布中' : '发布')
          .backgroundColor('transparent')
          .fontColor('#007AFF')
          .enabled(!this.isLoading)
          .onClick(() => this.handlePublish())
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      Row() {
        Button('📖 失物')
          .width('45%')
          .height(40)
          .backgroundColor(this.selectedType === 0 ? '#007AFF' : '#F5F5F5')
          .fontColor(this.selectedType === 0 ? '#FFFFFF' : '#666666')
          .borderRadius(20)
          .onClick(() => this.selectedType = 0)

        Button('🔍 招领')
          .width('45%')
          .height(40)
          .backgroundColor(this.selectedType === 1 ? '#007AFF' : '#F5F5F5')
          .fontColor(this.selectedType === 1 ? '#FFFFFF' : '#666666')
          .borderRadius(20)
          .onClick(() => this.selectedType = 1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding(16)

      Scroll() {
        Column() {
          TextInput({ placeholder: '标题（必填）', text: this.title })
            .width('100%')
            .height(50)
            .margin({ bottom: 16 })
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => this.title = value)

          TextArea({ placeholder: '详细描述（必填）', text: this.description })
            .width('100%')
            .height(120)
            .margin({ bottom: 16 })
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => this.description = value)

          TextInput({ placeholder: '地点（必填）', text: this.location })
            .width('100%')
            .height(50)
            .margin({ bottom: 16 })
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => this.location = value)

          TextInput({ placeholder: '联系方式（必填）', text: this.contact })
            .width('100%')
            .height(50)
            .margin({ bottom: 16 })
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => this.contact = value)

          Row() {
             Text('分类')
               .fontSize(16)
               .fontColor('#333333')
             Blank()
             Text(this.category || '请选择')
               .fontSize(16)
               .fontColor(this.category ? '#333333' : '#999999')
             Text(' >')
               .fontSize(16)
               .fontColor('#999999')
               .margin({ left: 4 })
           }
           .width('100%')
           .height(50)
           .padding({ left: 12, right: 12 })
           .backgroundColor('#F5F5F5')
           .borderRadius(8)
           .margin({ bottom: 16 })
           .onClick(() => {
             this.categoryDialogController.open();
           })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}