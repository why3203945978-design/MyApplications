import dataPreferences from '@ohos.data.preferences';

export class PreferencesUtil {
  private static preferences: dataPreferences.Preferences;
  private static instance: PreferencesUtil;

  static async getInstance(context: Context): Promise<PreferencesUtil> {
    if (!PreferencesUtil.instance) {
      PreferencesUtil.instance = new PreferencesUtil();
      PreferencesUtil.preferences = await dataPreferences.getPreferences(context, 'lost_and_found');
    }
    return PreferencesUtil.instance;
  }

  async putString(key: string, value: string): Promise<void> {
    await PreferencesUtil.preferences.put(key, value);
    await PreferencesUtil.preferences.flush();
  }

  async getString(key: string, defaultValue: string = ''): Promise<string> {
    return await PreferencesUtil.preferences.get(key, defaultValue) as string;
  }

  async putBoolean(key: string, value: boolean): Promise<void> {
    await PreferencesUtil.preferences.put(key, value);
    await PreferencesUtil.preferences.flush();
  }

  async getBoolean(key: string, defaultValue: boolean = false): Promise<boolean> {
    return await PreferencesUtil.preferences.get(key, defaultValue) as boolean;
  }

  async putArray<T>(key: string, value: Array<T>): Promise<void> {
    await PreferencesUtil.preferences.put(key, JSON.stringify(value));
    await PreferencesUtil.preferences.flush();
  }

  async getArray<T>(key: string, defaultValue: Array<T> = []): Promise<Array<T>> {
    const str = await PreferencesUtil.preferences.get(key, '[]') as string;
    try {
      return JSON.parse(str) as Array<T>;
    } catch {
      return defaultValue;
    }
  }

  async clear(): Promise<void> {
    await PreferencesUtil.preferences.clear();
    await PreferencesUtil.preferences.flush();
  }
}