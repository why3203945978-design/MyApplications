import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { LostItem, ItemType, ItemStatus } from '../model/DataModel';
import { LostItemCard } from '../components/LostItemCard';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';

const categories: string[] = ['证件', '电子产品', '包包', '衣物', '雨具', '学习用品', '生活用品', '其他'];

@Entry
@Component
struct SearchPage {
  @State searchText: string = '';
  @State searchResults: LostItem[] = [];
  @State isLoading: boolean = false;
  @State selectedFilter: string = 'all';
  @State showHistory: boolean = true;
  @State searchHistory: string[] = [];
  @State selectedCategory: string = '';
  @State allItems: LostItem[] = [];
  private prefUtil: PreferencesUtil | null = null;

  async aboutToAppear() {
    this.prefUtil = await PreferencesUtil.getInstance(getContext(this));
    this.loadSearchHistory();
    this.loadAllItems();
  }

  async loadAllItems() {
    if (this.prefUtil) {
      const lostItems = await this.prefUtil.getArray<LostItem>('lostItems', []);
      const foundItems = await this.prefUtil.getArray<LostItem>('foundItems', []);
      this.allItems = [...lostItems, ...foundItems];
      this.searchResults = this.allItems;
    }
  }

  loadSearchHistory() {
    this.searchHistory = ['书包', '校园卡', '电脑', '雨伞'];
  }

  saveSearchHistory(keyword: string) {
    if (!keyword || this.searchHistory.includes(keyword)) return;
    this.searchHistory.unshift(keyword);
    if (this.searchHistory.length > 10) {
      this.searchHistory.pop();
    }
  }

  clearHistory() {
    this.searchHistory = [];
    this.showToast('搜索历史已清空');
  }

  performSearch() {
    this.isLoading = true;
    this.showHistory = false;

    if (this.searchText.trim()) {
      this.saveSearchHistory(this.searchText);
    }

    setTimeout(() => {
      const keyword = this.searchText.toLowerCase();
      this.searchResults = this.allItems.filter(item => {
        const matchKeyword = !keyword ||
          item.title.toLowerCase().includes(keyword) ||
          item.description.toLowerCase().includes(keyword) ||
          item.location.toLowerCase().includes(keyword) ||
          item.category.toLowerCase().includes(keyword);

        const matchCategory = !this.selectedCategory || item.category === this.selectedCategory;

        return matchKeyword && matchCategory;
      });

      this.applyFilter();
      this.isLoading = false;
    }, 300);
  }

  applyFilter() {
    if (this.selectedFilter === 'lost') {
      this.searchResults = this.searchResults.filter(item => item.type === ItemType.LOST);
    } else if (this.selectedFilter === 'found') {
      this.searchResults = this.searchResults.filter(item => item.type === ItemType.FOUND);
    }
  }

  onFilterChange(filter: string) {
    this.selectedFilter = filter;
    if (!this.showHistory) {
      this.applyFilter();
    }
  }

  showToast(message: string) {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  goToDetail(item: LostItem) {
    router.push({
      url: 'pages/DetailPage',
      params: { item: JSON.stringify(item) }
    });
  }

  build() {
    Column() {
      Row() {
        Button('←')
          .fontSize(24)
          .backgroundColor('transparent')
          .onClick(() => router.back())

        TextInput({ placeholder: '搜索失物/招领...', text: this.searchText })
          .height(40)
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .margin({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.searchText = value;
          })
          .onSubmit(() => {
            this.performSearch();
          })

        Button('搜索')
          .backgroundColor('#007AFF')
          .borderRadius(20)
          .fontSize(14)
          .padding({ left: 16, right: 16 })
          .onClick(() => this.performSearch())
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      List({ scroller: new Scroller() }) {
        ForEach(categories, (cat: string) => {
          ListItem() {
            Text(cat)
              .fontSize(14)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.selectedCategory === cat ? '#007AFF' : '#F5F5F5')
              .fontColor(this.selectedCategory === cat ? '#FFFFFF' : '#666666')
              .borderRadius(16)
              .margin({ right: 8 })
              .onClick(() => {
                if (this.selectedCategory === cat) {
                  this.selectedCategory = '';
                } else {
                  this.selectedCategory = cat;
                }
                this.performSearch();
              })
          }
        }, (cat: string) => cat)
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .backgroundColor('#FFFFFF')
      .height(44)
      .padding({ left: 16, right: 16 })

      if (!this.showHistory) {
        Row() {
          Button('全部')
            .backgroundColor(this.selectedFilter === 'all' ? '#007AFF' : '#F5F5F5')
            .fontColor(this.selectedFilter === 'all' ? '#FFFFFF' : '#666666')
            .borderRadius(20)
            .padding({ left: 16, right: 16 })
            .onClick(() => this.onFilterChange('all'))

          Button('失物')
            .backgroundColor(this.selectedFilter === 'lost' ? '#007AFF' : '#F5F5F5')
            .fontColor(this.selectedFilter === 'lost' ? '#FFFFFF' : '#666666')
            .borderRadius(20)
            .padding({ left: 16, right: 16 })
            .margin({ left: 12 })
            .onClick(() => this.onFilterChange('lost'))

          Button('招领')
            .backgroundColor(this.selectedFilter === 'found' ? '#007AFF' : '#F5F5F5')
            .fontColor(this.selectedFilter === 'found' ? '#FFFFFF' : '#666666')
            .borderRadius(20)
            .padding({ left: 16, right: 16 })
            .margin({ left: 12 })
            .onClick(() => this.onFilterChange('found'))
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#FFFFFF')
      }

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
      } else if (this.showHistory) {
        Scroll() {
          Column() {
            Row() {
              Text('搜索历史')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Blank()

              Text('清空')
                .fontSize(14)
                .fontColor('#007AFF')
                .onClick(() => this.clearHistory())
            }
            .width('100%')
            .margin({ bottom: 12 })

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(this.searchHistory, (history: string) => {
                Text(history)
                  .fontSize(14)
                  .fontColor('#666666')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .backgroundColor('#F5F5F5')
                  .borderRadius(20)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    this.searchText = history;
                    this.performSearch();
                  })
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 16 })
        }
        .scrollBar(BarState.Auto)
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      } else if (this.searchResults.length === 0) {
        Column() {
          Text('🔍')
            .fontSize(80)
            .margin({ top: 100 })
          Text('未找到相关物品')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 20 })
          Text('试试其他关键词')
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.searchResults, (item: LostItem) => {
            ListItem() {
              LostItemCard({ item: item })
                .onClick(() => this.goToDetail(item))
            }
          }, (item: LostItem) => item.id)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}