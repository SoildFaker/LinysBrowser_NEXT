import { webview } from '@kit.ArkWeb';
import { url_meow_to_resource } from '../utils/url_tools';

@Observed
export class TabLabel {
  timestamp: number;
  index_key: number;

  constructor(timestamp: number, index: number) {
    this.index_key = index;
    this.timestamp = timestamp;
  }
}

export class TabInfoPacked {
  controller: WebviewController;
  title: string;
  url: string;
  is_loading: boolean;
  loading_progress: number;

  constructor(title: string, url: string) {
    this.controller = new webview.WebviewController();
    this.title = title;
    this.url = url;
    this.is_loading = true;
    this.loading_progress = 0;
  }

  update_title() {
    this.title = this.controller.getTitle();
  }

  update_url() {
    this.url = this.controller.getUrl();
  }

  update_is_loading(is_loading: boolean) {
    this.is_loading = is_loading;
  }

  update_loading_progress(progress: number) {
    this.loading_progress = progress;
  }

  update_user_agent(ua: string): void {
    this.controller.setCustomUserAgent(ua)
  }
}

export class BunchOfTabs {
  Tabs: Array<TabInfoPacked> = [new TabInfoPacked("Meow", "url")];
  Labels: Array<TabLabel> = [new TabLabel(Date.now(), 0)];
  current_working_tab_index: number = 0;
  user_agent: string = ''

  loadUrl_onWorkingTab(url: string) {
    url = url_meow_to_resource(url);
    this.Tabs[this.current_working_tab_index].controller.loadUrl(url);
  }

  refresh_onWorkingTab() {
    this.Tabs[this.current_working_tab_index].controller.refresh();
  }

  stop_onWorkingTab() {
    this.Tabs[this.current_working_tab_index].controller.stop();
  }

  goForward_onWorkingTab() {
    if (this.Tabs[this.current_working_tab_index].controller.accessForward()) {
      this.Tabs[this.current_working_tab_index].controller.forward();
    }
  }

  goBackward_onWorkingTab() {
    if (this.Tabs[this.current_working_tab_index].controller.accessBackward()) {
      this.Tabs[this.current_working_tab_index].controller.backward();
    }
  }

  switchToTab(target: number) {
    this.current_working_tab_index = target;
    return target;
  }

  newTab(home_url: string) {
    let new_TabInfo: TabInfoPacked = new TabInfoPacked("Meow", home_url);
    let new_TabLabel: TabLabel = new TabLabel(Date.now(), this.Tabs.length);
    this.Tabs.push(new_TabInfo);
    this.Labels.push(new_TabLabel);
    this.current_working_tab_index = this.Tabs.length - 1;
    return this.Tabs.length - 1 as number;
    // return this.switchToTab(this.Tabs.length - 1) as number;
  }

  closeTab(target: number, home_url: string) {
    home_url = url_meow_to_resource(home_url);
    if (this.Tabs.length == 1) {
      // Reset the only tab
      this.Tabs[0].controller.loadUrl(home_url);
      this.Tabs[0].controller.clearHistory();
      return 0;
    }
    // Now at least 2 items are in the Tabs list

    let landing_destination = this.current_working_tab_index
    // Decide where to go

    if (this.current_working_tab_index == target) {
      // If deleting the tab currently viewing
      if (target == 0) {
        landing_destination = 1;
        // If deleting the top tab
      } else if (target == this.Tabs.length - 1) {
        landing_destination = this.Tabs.length - 2;
        // If deleting the last tab
      } else {
        landing_destination = target - 1;
        // If in the middle
      }
    } else {

    }

    this.switchToTab(0)
    // Forces LinysTabs to refresh For Each loop to render
    this.switchToTab(landing_destination)

    this.Tabs.splice(target, 1)
    this.Labels.splice(target, 1)

    for (let i = target; i < this.Labels.length; ++i) {
      this.Labels[i].index_key -= 1
    }

    if (this.current_working_tab_index > target) {
      this.current_working_tab_index -= 1;
    }

    return this.current_working_tab_index
  }

  workingTab() {
    return this.Tabs[this.current_working_tab_index];
  }

  get_all_titles() {
    let titles: string[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      titles.push(this.Tabs[index].title);
    }
    return titles;
  }

  get_all_urls() {
    let urls: string[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      urls.push(this.Tabs[index].url);
    }
    return urls;
  }

  get_all_is_loading() {
    let is_loading: boolean[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      is_loading.push(this.Tabs[index].is_loading);
    }
    return is_loading;
  }

  get_all_loading_progress() {
    let progress: number[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      progress.push(this.Tabs[index].loading_progress);
    }
    return progress;
  }

  get_all_time_stamps() {
    let stamps: number[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      stamps.push(this.Labels[index].timestamp);
    }
    return stamps;
  }

  set_all_user_agent(ua: string) {
    this.user_agent = ua;
    for (let index = 0; index < this.Tabs.length; index++) {
      this.Tabs[index].controller.setCustomUserAgent(this.user_agent)
    }
  }
}