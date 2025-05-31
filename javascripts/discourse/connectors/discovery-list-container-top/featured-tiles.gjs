import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";
import FeaturedTiles from "../../components/featured-tiles";

@tagName("span")
@classNames("discovery-list-container-top-outlet", "featured-tiles")
export default class FeaturedTilesConnector extends Component {
  static shouldRender() {
    let val = window.localStorage.getItem("show_featured_topics_banner");
    if (val === "false") {
      val = false;
    }
    if (val === null) {
      val = true;
    }
    return val;
  }

  <template><FeaturedTiles @category={{this.category}} /></template>
}
