import Component from "@ember/component";
import { classNames } from "@ember-decorators/component";
import PreferenceCheckbox from "discourse/components/preference-checkbox";
import User from "discourse/models/user";
import { i18n } from "discourse-i18n";

@classNames("user-preferences-interface-outlet", "featured-tiles")
export default class FeaturedTiles extends Component {
  static shouldRender(component) {
    return component.model.id === User.current().id;
  }

  <template>
    <div class="control-group other">
      <label class="control-label">{{i18n
          (themePrefix "preference_header")
        }}</label>

      <PreferenceCheckbox
        @labelKey={{themePrefix "preference_description"}}
        @checked={{this.model.show_featured_topics_banner}}
      />
    </div>
  </template>
}
