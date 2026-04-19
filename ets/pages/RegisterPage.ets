import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';
import { User } from '../model/DataModel';

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State phone: string = '';
  @State email: string = '';
  @State schoolId: string = '';
  @State isLoading: boolean = false;
  private prefUtil: PreferencesUtil | null = null;

  async aboutToAppear() {
    this.prefUtil = await PreferencesUtil.getInstance(getContext(this));
  }

  showToast(message: string) {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  async handleRegister() {
    if (!this.username || !this.password || !this.confirmPassword || !this.phone || !this.schoolId) {
      this.showToast('请填写完整信息');
      return;
    }

    if (!this.phone.match(/^1[3-9]\d{9}$/)) {
      this.showToast('请输入正确的手机号');
      return;
    }

    if (this.email && !this.email.includes('@')) {
      this.showToast('请输入正确的邮箱');
      return;
    }

    if (this.password.length < 6) {
      this.showToast('密码至少6位');
      return;
    }

    if (this.password !== this.confirmPassword) {
      this.showToast('两次输入的密码不一致');
      return;
    }

    if (this.prefUtil) {
      interface UserWithPassword extends User {
        password: string;
      }
      const registeredUsers = await this.prefUtil.getArray<UserWithPassword>('registeredUsers', []);
      if (registeredUsers.some(u => u.username === this.username)) {
        this.showToast('用户名已存在');
        return;
      }

      this.isLoading = true;

      try {
        const newUser: UserWithPassword = {
          id: Date.now().toString(),
          username: this.username,
          password: this.password,
          avatar: '',
          phone: this.phone,
          email: this.email || `${this.username}@school.edu`,
          schoolId: this.schoolId
        };
        
        console.log('注册用户:', JSON.stringify(newUser));
        
        registeredUsers.push(newUser);
        console.log('注册后用户列表:', JSON.stringify(registeredUsers));
        
        await this.prefUtil.putArray('registeredUsers', registeredUsers);
        console.log('保存成功');
        
        await this.prefUtil.putString('userInfo', JSON.stringify(newUser));
        await this.prefUtil.putBoolean('isLogin', true);
        
        this.showToast('注册成功');
        this.isLoading = false;
        router.replace({ url: 'pages/HomePage' });
      } catch (error) {
        console.error('注册失败:', error);
        this.showToast('注册失败，请稍后重试');
        this.isLoading = false;
      }
    }
  }

  build() {
    Column() {
      Row() {
        Text('📝')
          .fontSize(60)
          .margin({ top: 40 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Text('注册账号')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 40 })
        .fontColor('#333333')

      Column() {
        TextInput({ placeholder: '用户名', text: this.username })
          .width('90%')
          .height(50)
          .margin({ bottom: 15 })
          .backgroundColor('#F5F5F5')
          .borderRadius(25)
          .padding({ left: 20 })
          .onChange((value: string) => {
            this.username = value;
          })

        TextInput({ placeholder: '密码', text: this.password })
          .width('90%')
          .height(50)
          .margin({ bottom: 15 })
          .backgroundColor('#F5F5F5')
          .borderRadius(25)
          .padding({ left: 20 })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value;
          })

        TextInput({ placeholder: '确认密码', text: this.confirmPassword })
          .width('90%')
          .height(50)
          .margin({ bottom: 15 })
          .backgroundColor('#F5F5F5')
          .borderRadius(25)
          .padding({ left: 20 })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.confirmPassword = value;
          })

        TextInput({ placeholder: '手机号', text: this.phone })
          .width('90%')
          .height(50)
          .margin({ bottom: 15 })
          .backgroundColor('#F5F5F5')
          .borderRadius(25)
          .padding({ left: 20 })
          .onChange((value: string) => {
            this.phone = value;
          })

        TextInput({ placeholder: '邮箱（可选）', text: this.email })
          .width('90%')
          .height(50)
          .margin({ bottom: 15 })
          .backgroundColor('#F5F5F5')
          .borderRadius(25)
          .padding({ left: 20 })
          .onChange((value: string) => {
            this.email = value;
          })

        TextInput({ placeholder: '学号', text: this.schoolId })
          .width('90%')
          .height(50)
          .margin({ bottom: 30 })
          .backgroundColor('#F5F5F5')
          .borderRadius(25)
          .padding({ left: 20 })
          .onChange((value: string) => {
            this.schoolId = value;
          })

        Button(this.isLoading ? '注册中...' : '注册')
          .width('90%')
          .height(50)
          .backgroundColor('#007AFF')
          .borderRadius(25)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleRegister();
          })

        Row() {
          Text('已有账号？去登录')
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