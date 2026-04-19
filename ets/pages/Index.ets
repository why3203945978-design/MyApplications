import router from '@ohos.router';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';

@Entry
@Component
struct Index {
  @State progress: number = 0;
  private prefUtil: PreferencesUtil | null = null;

  async aboutToAppear() {
    this.prefUtil = await PreferencesUtil.getInstance(getContext(this));

    let interval = setInterval(() => {
      if (this.progress >= 100) {
        clearInterval(interval);
        this.checkLoginStatus();
      } else {
        this.progress += 2;
      }
    }, 20);
  }
  async checkLoginStatus() {
    if (this.prefUtil) {
      const isLogin = await this.prefUtil.getBoolean('isLogin', false);
      if (isLogin) {
        router.replace({ url: 'pages/HomePage' });
      } else {
        router.replace({ url: 'pages/LoginPage' });
      }
    }
  }

  build() {
    Column() {
      Text('🏫')
        .fontSize(80)
        .margin({ top: 100 })

      Text('校园失物招领')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 20 })

      Text('Lost & Found')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 8 })

      Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
        .width('60%')
        .height(4)
        .color('#007AFF')
        .margin({ top: 60 })

      Text(`${this.progress}%`)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor('#FFFFFF')
  }
}