import formBindingData from '@ohos.app.form.formBindingData';
import formInfo from '@ohos.app.form.formInfo';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import Want from '@ohos.app.ability.Want';

interface RecentItem {
  title: string;
  location: string;
  time: string;
}

interface FormData {
  title: string;
  lostCount: string;
  foundCount: string;
  recentItems: RecentItem[];
}

export default class LostWidget extends FormExtensionAbility {
  onAddForm(want: Want) {
    let formData: FormData = {
      title: '校园失物招领',
      lostCount: '3',
      foundCount: '2',
      recentItems: [
        { title: '蓝色书包', location: '图书馆', time: '2小时前' },
        { title: '校园卡', location: '食堂', time: '昨天' }
      ]
    };

    let formInfo = formBindingData.createFormBindingData(formData);
    return formInfo;
  }

  onCastToNormalForm(formId: string) {
  }

  onUpdateForm(formId: string) {
    let formData: FormData = {
      title: '校园失物招领',
      lostCount: Math.floor(Math.random() * 10).toString(),
      foundCount: Math.floor(Math.random() * 8).toString(),
      recentItems: [
        { title: '更新的物品', location: '教学楼', time: '刚刚' }
      ]
    };

    let formInfo = formBindingData.createFormBindingData(formData);
    // FormExtensionAbility 中更新表单的正确方式
    return formInfo;
  }

  onChangeFormVisibility(newStatus: Record<string, number>) {
  }

  onFormEvent(formId: string, message: string) {
    console.log(`Form event: ${message}`);
  }

  onRemoveForm(formId: string) {
  }

  onAcquireFormState(want: Want) {
    return formInfo.FormState.READY;
  }
}