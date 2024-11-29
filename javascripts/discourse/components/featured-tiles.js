import Component from "@ember/component";
import { next } from "@ember/runloop";
import { service } from "@ember/service";
import { classNameBindings } from "@ember-decorators/component";
import { observes } from "@ember-decorators/object";
import discourseComputed from "discourse-common/utils/decorators";

const displayCategories = settings.display_categories
  .split("|")
  .map((id) => parseInt(id, 10))
  .filter((id) => id);

const featuredTags = settings.featured_tags.split("|").filter(Boolean);

function shuffle(array) {
  array = [...array];

  // https://stackoverflow.com/a/12646864
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }

  return array;
}

@classNameBindings("isLoading")
export default class FeaturedTiles extends Component {
  @service router;

  isLoading = true;

  init() {
    super.init();
    this.set("isLoading", true);
    this.loadTopics();
  }

  @observes("category")
  categoryChanged() {
    if (settings.scope_to_category) {
      this.loadTopics();
    }
  }

  loadTopics() {
    const loadParams = { period: settings.top_period };

    if (featuredTags.length) {
      loadParams.tags = featuredTags;
    }

    if (settings.featured_category > 0) {
      loadParams.category = settings.featured_category;
    }

    if (settings.scope_to_category && this.category) {
      loadParams.category = this.category.id;
    }

    this.store
      .findFiltered("topicList", {
        filter: settings.topic_source,
        params: loadParams,
      })
      .then((list) => {
        this.set("list", list);
        next(this, () => this.set("isLoading", false)); // Use `next` for CSS animation
      });
  }

  @discourseComputed("list.topics")
  filteredTopics(topics) {
    if (!topics) {
      return;
    }
    if (settings.randomize_topics) {
      topics = shuffle(topics);
    }
    return topics.slice(0, settings.maximum_topic_count);
  }

  @discourseComputed(
    "site.mobileView",
    "category.id",
    "router.currentRouteName"
  )
  shouldDisplay(isMobile, viewingCategoryId, currentRouteName) {
    if (
      ![
        "discovery.latest",
        "discovery.categories",
        "discovery.category",
      ].includes(currentRouteName)
    ) {
      return false;
    }

    if (isMobile && !settings.display_mobile) {
      return false;
    }
    if (settings.display_when_unfiltered && !viewingCategoryId) {
      return true;
    }

    if (settings.display_on_categories && viewingCategoryId) {
      if (displayCategories.length === 0) {
        return true;
      }
      return displayCategories.includes(viewingCategoryId);
    }
    return false;
  }
}
