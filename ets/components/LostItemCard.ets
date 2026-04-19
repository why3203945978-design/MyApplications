import { LostItem, ItemType, ItemStatus } from '../model/DataModel';

@Component
export struct LostItemCard {
  @Prop item: LostItem;
  onAction?: (item: LostItem) => void;

  getTypeIcon(): string {
    if (this.item.category) {
      switch (this.item.category) {
        case '证件': return '📄';
        case '电子产品': return '📱';
        case '包包': return '👜';
        case '衣物': return '👔';
        case '雨具': return '☂️';
        case '学习用品': return '📚';
        case '生活用品': return '🏠';
        case '其他': return this.item.type === ItemType.LOST ? '📖' : '🔍';
        default: return this.item.type === ItemType.LOST ? '📖' : '🔍';
      }
    }
    return this.item.type === ItemType.LOST ? '📖' : '🔍';
  }

  getTypeColor(): string {
    if (this.item.category) {
      switch (this.item.category) {
        case '证件': return '#3498db';
        case '电子产品': return '#e74c3c';
        case '包包': return '#9b59b6';
        case '衣物': return '#f39c12';
        case '雨具': return '#1abc9c';
        case '学习用品': return '#2ecc71';
        case '生活用品': return '#d35400';
        case '其他': return this.item.type === ItemType.LOST ? '#FF6B6B' : '#4ECDC4';
        default: return this.item.type === ItemType.LOST ? '#FF6B6B' : '#4ECDC4';
      }
    }
    return this.item.type === ItemType.LOST ? '#FF6B6B' : '#4ECDC4';
  }

  getStatusColor(): string {
    switch (this.item.status) {
      case ItemStatus.LOST:
        return '#FF9800';
      case ItemStatus.FOUND:
        return '#4CAF50';
      case ItemStatus.CLAIMED:
        return '#9E9E9E';
      case ItemStatus.RETURNED:
        return '#2196F3';
      default:
        return '#999999';
    }
  }

  getStatusText(): string {
    switch (this.item.status) {
      case ItemStatus.LOST:
        return '寻找中';
      case ItemStatus.FOUND:
        return '待认领';
      case ItemStatus.CLAIMED:
        return '已认领';
      case ItemStatus.RETURNED:
        return '已归还';
      default:
        return '未知';
    }
  }

  getTimeAgo(date: Date): string {
    const now = new Date();
    const diff = now.getTime() - new Date(date).getTime();
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    if (days === 0) return '今天';
    if (days === 1) return '昨天';
    if (days < 7) return `${days}天前`;
    if (days < 30) return `${Math.floor(days / 7)}周前`;
    return `${Math.floor(days / 30)}月前`;
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.getTypeIcon())
            .fontSize(28)
        }
        .width(50)
        .height(50)
        .backgroundColor(`${this.getTypeColor()}20`)
        .borderRadius(25)
        .justifyContent(FlexAlign.Center)

        Column() {
          Text(this.item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.item.description)
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })

          Row() {
            Text('📍')
              .fontSize(12)
            Text(this.item.location)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ left: 2 })
          }
          .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })

        Column() {
          Text(this.getStatusText())
            .fontSize(11)
            .fontColor(this.getStatusColor())
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
            .backgroundColor(`${this.getStatusColor()}20`)

          Text(this.getTimeAgo(this.item.createdAt))
            .fontSize(11)
            .fontColor('#CCCCCC')
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

    }
    .width('100%')
    .margin({ bottom: 12 })
    .shadow({ radius: 4, color: '#00000010' })
  }
}