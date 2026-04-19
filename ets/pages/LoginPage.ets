import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';
import { User } from '../model/DataModel';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  private prefUtil: PreferencesUtil | null = null;
  async aboutToAppear() {
    this.prefUtil = await PreferencesUtil.getInstance(getContext(this));
    if (this.prefUtil) {
      const isLogin = await this.prefUtil.getBoolean('isLogin', false);
      if (isLogin) {
        router.replace({ url: 'pages/HomePage' });
      }
    }
  }

  async handleLogin() {
    if (!this.username || !this.password) {
      this.showToast('请输入用户名和密码');
      return;
    }

    this.isLoading = true;

    try {
      if (this.prefUtil) {
        interface UserWithPassword extends User {
          password: string;
        }
        const registeredUsers = await this.prefUtil.getArray<UserWithPassword>('registeredUsers', []);
        console.log('登录时用户列表:', JSON.stringify(registeredUsers));
        console.log('登录尝试:', this.username, this.password);
        
        const user = registeredUsers.find(u => 
          (u.username === this.username || u.phone === this.username) && 
          u.password === this.password
        );
        console.log('找到用户:', JSON.stringify(user));
        
        if (user) {
          await this.prefUtil.putString('userInfo', JSON.stringify(user));
          await this.prefUtil.putBoolean('isLogin', true);
          
          this.showToast('登录成功');
          this.isLoading = false;
          router.replace({ url: 'pages/HomePage' });
        } else {
          this.showToast('用户名或密码错误');
          this.isLoading = false;
        }
      } else {
        this.showToast('系统错误，请稍后重试');
        this.isLoading = false;
      }
    } catch (error) {
      console.error('登录失败:', error);
      this.showToast('登录失败，请稍后重试');
      this.isLoading = false;
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
        Text('🏫')
          .fontSize(80)
          .margin({ top: 60 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Text('校园失物招领')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 40 })
        .fontColor('#333333')

      Column() {
        TextInput({ placeholder: '学号/手机号', text: this.username })
          .width('90%')
          .height(50)
          .margin({ bottom: 20 })
          .backgroundColor('#F5F5F5')
          .borderRadius(25)
          .padding({ left: 20 })
          .onChange((value: string) => {
            this.username = value;
          })

        TextInput({ placeholder: '密码', text: this.password })
          .width('90%')
          .height(50)
          .margin({ bottom: 30 })
          .backgroundColor('#F5F5F5')
          .borderRadius(25)
          .padding({ left: 20 })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value;
          })

        Button(this.isLoading ? '登录中...' : '登录')
          .width('90%')
          .height(50)
          .backgroundColor('#007AFF')
          .borderRadius(25)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleLogin();
          })

        Row() {
          Text('忘记密码？')
            .fontSize(14)
            .fontColor('#666666')
            .onClick(() => {
              router.push({ url: 'pages/ForgotPasswordPage' });
            })

          Blank()

          Text('注册账号')
            .fontSize(14)
            .fontColor('#007AFF')
            .onClick(() => {
              router.push({ url: 'pages/RegisterPage' });
            })
        }
        .width('90%')
        .margin({ top: 20 })
      }
      .width('100%')
      .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}