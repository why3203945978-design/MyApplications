// widget/LostWidgetPage.ets
import formBindingData from '@ohos.app.form.formBindingData';

interface FormData {
  lostCount?: number;
  foundCount?: number;
}

@Entry
@Component
struct LostWidgetPage {
  @State title: string = '校园失物招领';
  @State lostCount: number = 3;
  @State foundCount: number = 2;

  aboutToAppear() {
    // 小组件数据由 FormExtensionAbility 管理
    // 这里使用默认值，后续会由 onUpdateForm 方法更新
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 8, left: 12 })

      Row() {
        Column() {
          Text('📖')
            .fontSize(20)
          Text(`失物 ${this.lostCount}`)
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('🔍')
            .fontSize(20)
          Text(`招领 ${this.foundCount}`)
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .margin({ top: 12, bottom: 12 })

      Divider()
        .height(1)
        .color('#E0E0E0')

      Text('快速发布')
        .fontSize(14)
        .fontColor('#007AFF')
        .margin({ top: 8, bottom: 8 })
        .onClick(() => {
          // 跳转到发布页面
          postCardAction(this, {
            action: 'router',
            abilityName: 'EntryAbility',
            params: {
              targetPage: 'pages/PublishPage'
            }
          });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}