import Component from "@ember/component";
import { classNames } from "@ember-decorators/component";
import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";
import discourseComputed from "discourse/lib/decorators";

@classNames("featured-tile")
export default class FeaturedTile extends Component {
  responsiveRatios = [1, 1.5, 2];
  displayHeight = 200;
  displayWidth = 200;

  @discourseComputed("topic.thumbnails")
  srcset() {
    return this.responsiveRatios
      .map((ratio) => {
        const match = this.findBest(
          ratio * this.displayHeight,
          ratio * this.displayWidth
        );
        return `${match.url} ${ratio}x`;
      })
      .join(",");
  }

  @discourseComputed("topic.thumbnails")
  original(thumbnails) {
    return thumbnails[0];
  }

  @discourseComputed("original")
  width(original) {
    return original.width;
  }

  @discourseComputed("original")
  height(original) {
    return original.height;
  }

  @discourseComputed("topic.thumbnails")
  fallbackSrc() {
    return this.findBest(this.displayWidth, this.displayHeight).url;
  }

  findBest(maxWidth, maxHeight) {
    if (!this.topic.thumbnails) {
      return;
    }

    const largeEnough = this.topic.thumbnails.filter((t) => {
      if (!t.url) {
        return false;
      }
      return t.max_width >= maxHeight;
    });

    if (largeEnough.lastObject) {
      return largeEnough.lastObject;
    }

    return this.original;
  }

  @discourseComputed("topic")
  url(topic) {
    return topic.linked_post_number
      ? topic.urlForPostNumber(topic.linked_post_number)
      : topic.get("lastUnreadUrl");
  }

  <template>
    <a href={{this.url}}>
      {{#if this.topic.thumbnails}}
        <img
          src={{this.fallbackSrc}}
          srcset={{this.srcset}}
          width={{this.width}}
          height={{this.height}}
          loading="lazy"
          class="topic-tile-thumbnail"
        />
      {{/if}}

      <div class="topic-info">
        <span class="topic-title">{{this.topic.title}}</span>
        <span class="author">
          <UserLink @user={{this.topic.creator}}>
            {{avatar this.topic.creator imageSize="large"}}
          </UserLink>
        </span>
      </div>
    </a>
  </template>
}
