import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';

@Entry
@Component
struct ForgotPasswordPage {
  @State phone: string = '';
  @State verificationCode: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State isCounting: boolean = false;
  @State countdown: number = 60;
  private prefUtil: PreferencesUtil | null = null;
  private countdownTimer: number | null = null;

  async aboutToAppear() {
    this.prefUtil = await PreferencesUtil.getInstance(getContext(this));
  }

  showToast(message: string) {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  startCountdown() {
    if (!this.isCounting) {
      this.isCounting = true;
      this.countdown = 60;
      this.countdownTimer = setInterval(() => {
        if (this.countdown > 0) {
          this.countdown--;
        } else {
          this.isCounting = false;
          if (this.countdownTimer) {
            clearInterval(this.countdownTimer);
            this.countdownTimer = null;
          }
        }
      }, 1000);
    }
  }

  sendVerificationCode() {
    if (!this.phone || !this.phone.match(/^1[3-9]\d{9}$/)) {
      this.showToast('请输入正确的手机号');
      return;
    }
    this.showToast('验证码已发送（测试环境）');
    this.startCountdown();
  }

  async resetPassword() {
    if (!this.phone || !this.verificationCode || !this.newPassword || !this.confirmPassword) {
      this.showToast('请填写完整信息');
      return;
    }

    if (!this.phone.match(/^1[3-9]\d{9}$/)) {
      this.showToast('请输入正确的手机号');
      return;
    }

    if (this.newPassword.length < 6) {
      this.showToast('密码至少6位');
      return;
    }

    if (this.newPassword !== this.confirmPassword) {
      this.showToast('两次输入的密码不一致');
      return;
    }

    if (this.verificationCode !== '123456') {
      this.showToast('验证码错误（测试验证码：123456）');
      return;
    }

    if (this.prefUtil) {
      interface UserWithPassword {
        id: string;
        username: string;
        password: string;
        avatar: string;
        phone: string;
        email: string;
        schoolId: string;
      }
      const registeredUsers = await this.prefUtil.getArray<UserWithPassword>('registeredUsers', []);
      const userIndex = registeredUsers.findIndex(u => u.phone === this.phone);
      
      if (userIndex === -1) {
        this.showToast('该手机号未注册');
        return;
      }
    }

    this.isLoading = true;

    setTimeout(async () => {
      if (this.prefUtil) {
        interface UserWithPassword {
          id: string;
          username: string;
          password: string;
          avatar: string;
          phone: string;
          email: string;
          schoolId: string;
        }
        let registeredUsers = await this.prefUtil.getArray<UserWithPassword>('registeredUsers', []);
        const userIndex = registeredUsers.findIndex(u => u.phone === this.phone);
        
        if (userIndex !== -1) {
          registeredUsers[userIndex].password = this.newPassword;
          await this.prefUtil.putArray('registeredUsers', registeredUsers);
          this.showToast('密码重置成功');
          this.isLoading = false;
          router.back();
        }
      }
    }, 1000);
  }

  build() {
    Column() {
      Row() {
        Text('🔐')
          .fontSize(60)
          .margin({ top: 40 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Text('找回密码')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 40 })
        .fontColor('#333333')

      Column() {
        TextInput({ placeholder: '手机号', text: this.phone })
          .width('90%')
          .height(50)
          .margin({ bottom: 20 })
          .backgroundColor('#F5F5F5')
          .borderRadius(25)
          .padding({ left: 20 })
          .onChange((value: string) => {
            this.phone = value;
          })

        Row() {
          TextInput({ placeholder: '验证码', text: this.verificationCode })
            .width('60%')
            .height(50)
            .backgroundColor('#F5F5F5')
            .borderRadius(25)
            .padding({ left: 20 })
            .onChange((value: string) => {
              this.verificationCode = value;
            })

          Button(this.isCounting ? `${this.countdown}s后重发` : '获取验证码')
            .width('30%')
            .height(50)
            .backgroundColor('#007AFF')
            .borderRadius(25)
            .fontSize(14)
            .enabled(!this.isCounting)
            .onClick(() => {
              this.sendVerificationCode();
            })
        }
        .width('90%')
        .margin({ bottom: 20 })

        TextInput({ placeholder: '新密码', text: this.newPassword })
          .width('90%')
          .height(50)
          .margin({ bottom: 20 })
          .backgroundColor('#F5F5F5')
          .borderRadius(25)
          .padding({ left: 20 })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.newPassword = value;
          })

        TextInput({ placeholder: '确认密码', text: this.confirmPassword })
          .width('90%')
          .height(50)
          .margin({ bottom: 30 })
          .backgroundColor('#F5F5F5')
          .borderRadius(25)
          .padding({ left: 20 })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.confirmPassword = value;
          })

        Button(this.isLoading ? '重置中...' : '重置密码')
          .width('90%')
          .height(50)
          .backgroundColor('#007AFF')
          .borderRadius(25)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.resetPassword();
          })

        Row() {
          Text('返回登录')
            .fontSize(14)
            .fontColor('#007AFF')
            .onClick(() => {
              router.back();
            })
        }
        .width('90%')
        .margin({ top: 20 })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}