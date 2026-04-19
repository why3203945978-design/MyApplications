import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { User } from '../model/DataModel';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';
import picker from '@ohos.file.picker';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';

@Entry
@Component
struct EditProfilePage {
  @State userInfo: User = {
    id: '',
    username: '',
    avatar: '',
    phone: '',
    email: '',
    schoolId: '',
    backgroundColor: '#FFFFFF'
  };
  @State isLoading: boolean = true;
  @State newUsername: string = '';
  @State newPhone: string = '';
  @State newEmail: string = '';
  @State newSchoolId: string = '';
  private prefUtil: PreferencesUtil | null = null;

  async aboutToAppear() {
    this.prefUtil = await PreferencesUtil.getInstance(getContext(this));
    if (this.prefUtil) {
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
        this.newUsername = this.userInfo.username;
        this.newPhone = this.userInfo.phone;
        this.newEmail = this.userInfo.email;
        this.newSchoolId = this.userInfo.schoolId;
      }
    }
    this.isLoading = false;
  }

  async saveChanges() {
    if (!this.newUsername) {
      this.showToast('请输入用户名');
      return;
    }

    if (!this.newPhone.match(/^1[3-9]\d{9}$/)) {
      this.showToast('请输入正确的手机号');
      return;
    }

    if (this.newEmail && !this.newEmail.includes('@')) {
      this.showToast('请输入正确的邮箱');
      return;
    }

    if (this.prefUtil) {
      const updatedUser: User = {
        id: this.userInfo.id,
        username: this.newUsername,
        avatar: this.userInfo.avatar,
        phone: this.newPhone,
        email: this.newEmail,
        schoolId: this.newSchoolId,
        backgroundColor: this.userInfo.backgroundColor
      };

      await this.prefUtil.putString('userInfo', JSON.stringify(updatedUser));
      this.showToast('保存成功');
      setTimeout(() => {
        router.back();
      }, 1000);
    }
  }

  showToast(message: string) {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  async requestPermission(): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const result = await atManager.requestPermissionsFromUser(getContext(this), ['ohos.permission.READ_MEDIA']);
      return result.authResults && result.authResults.length > 0 && result.authResults[0] === 0;
    } catch (error) {
      console.error('请求权限失败:', error);
      return false;
    }
  }

  async selectImage(): Promise<string | null> {
    const hasPermission = await this.requestPermission();
    if (!hasPermission) {
      this.showToast('需要相册权限才能选择图片');
      return null;
    }

    try {
      const photoPicker = new picker.PhotoViewPicker();
      const options = new picker.PhotoSelectOptions();
      options.maxSelectNumber = 1;
      
      const result = await photoPicker.select(options);
      if (result && result.photoUris && result.photoUris.length > 0) {
        return result.photoUris[0];
      }
    } catch (error) {
      console.error('选择图片失败:', error);
    }
    return null;
  }

  async selectAvatar() {
    const uri = await this.selectImage();
    if (uri) {
      this.userInfo.avatar = uri;
      if (this.prefUtil) {
        await this.prefUtil.putString('userInfo', JSON.stringify(this.userInfo));
      }
      this.showToast('头像已更新');
    }
  }



  build() {
    Column() {
      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .color('#007AFF')
          .margin({ top: 200 })
      } else {
        this.buildEditPage()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  buildEditPage() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('取消')
          .backgroundColor('transparent')
          .fontColor('#666666')
          .fontSize(16)
          .onClick(() => router.back())

        Text('编辑资料')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('保存')
          .backgroundColor('#007AFF')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .padding({ left: 16, right: 16 })
          .borderRadius(16)
          .onClick(() => this.saveChanges())
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 4,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 2
      })

      Scroll() {
        Column() {
          // 头像设置
          Column() {
            Stack() {
              Image(this.userInfo.avatar || 'https://via.placeholder.com/120')
                .width(120)
                .height(120)
                .borderRadius(60)
                .objectFit(ImageFit.Cover)
                .border({ width: 3, color: '#FFFFFF' })
                .shadow({
                  radius: 8,
                  color: 'rgba(0, 0, 0, 0.2)',
                  offsetX: 0,
                  offsetY: 4
                })
              
              Button() {
                Text('📷')
                  .fontSize(20)
              }
              .width(40)
              .height(40)
              .borderRadius(20)
              .backgroundColor('#007AFF')
              .position({ x: 80, y: 80 })
              .shadow({
                radius: 4,
                color: 'rgba(0, 0, 0, 0.2)',
                offsetX: 0,
                offsetY: 2
              })
              .onClick(() => this.selectAvatar())
            }
            .width(120)
            .height(120)
            
            Text('点击修改头像')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12 })
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .margin({ top: 40, bottom: 30 })

          // 个人信息编辑
          Column() {
            Text('个人信息')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 20 })
              .textAlign(TextAlign.Start)
            
            this.editRow('用户名', this.newUsername, (value: string) => this.newUsername = value)
            this.editRow('手机号', this.newPhone, (value: string) => this.newPhone = value, true)
            this.editRow('邮箱', this.newEmail, (value: string) => this.newEmail = value)
            this.editRow('学号', this.newSchoolId, (value: string) => this.newSchoolId = value, true)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: 4
          })

          // 背景设置
          Column() {
            Text('背景设置')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 20 })
              .textAlign(TextAlign.Start)
            
            Row() {
              this.backgroundOption('#FF6B6B', '红色')
              this.backgroundOption('#4ECDC4', '青色')
              this.backgroundOption('#45B7D1', '蓝色')
              this.backgroundOption('#96CEB4', '绿色')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
            .margin({ bottom: 20 })
            

          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: 4
          })
          .margin({ top: 20, bottom: 40 })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
  }

  @Builder
  editRow(label: string, value: string, onChange: (value: string) => void, readonly: boolean = false) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8 })
        .textAlign(TextAlign.Start)
      
      TextInput({
        placeholder: `请输入${label}`,
        text: value
      })
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .backgroundColor(readonly ? '#F0F0F0' : '#F8F9FA')
        .borderRadius(12)
        .fontSize(16)
        .fontColor('#333333')
        .enabled(!readonly)
        .onChange(onChange)
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  @Builder
  backgroundOption(color: string, name: string) {
    Column() {
      Stack() {
        Text('')
          .width(70)
          .height(70)
          .backgroundColor(color)
          .borderRadius(12)
          .shadow({
            radius: 4,
            color: 'rgba(0, 0, 0, 0.2)',
            offsetX: 0,
            offsetY: 2
          })
        Text(name)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
      }
      .width(70)
      .height(70)
      .onClick(() => {
        this.userInfo.backgroundColor = color;
        this.showToast(`已设置${name}背景`);
      })
    }
  }
}