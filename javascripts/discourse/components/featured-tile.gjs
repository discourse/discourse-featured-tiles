/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { computed } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";

@classNames("featured-tile")
export default class FeaturedTile extends Component {
  responsiveRatios = [1, 1.5, 2];
  displayHeight = 200;
  displayWidth = 200;

  @computed("topic.thumbnails")
  get srcset() {
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

  @computed("topic.thumbnails")
  get original() {
    return this.topic?.thumbnails?.[0];
  }

  @computed("original")
  get width() {
    return this.original.width;
  }

  @computed("original")
  get height() {
    return this.original.height;
  }

  @computed("topic.thumbnails")
  get fallbackSrc() {
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

  @computed("topic")
  get url() {
    return this.topic.linked_post_number
      ? this.topic.urlForPostNumber(this.topic.linked_post_number)
      : this.topic.get("lastUnreadUrl");
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
