        import { application } from "controllers/application"
        import {
          RailsuiClipboard,
          RailsuiCountUp,
          RailsuiCombobox,
          RailsuiDateRangePicker,
          RailsuiDropdown,
          RailsuiModal,
          RailsuiRange,
          RailsuiReadMore,
          RailsuiSelectAll,
          RailsuiTabs,
          RailsuiToast,
          RailsuiToggle,
          RailsuiTooltip
        } from "railsui-stimulus"

        // Register railsui-stimulus components
        application.register("railsui-clipboard", RailsuiClipboard)
        application.register("railsui-count-up", RailsuiCountUp)
        application.register("railsui-combobox", RailsuiCombobox)
        application.register("railsui-date-range-picker", RailsuiDateRangePicker)
        application.register("railsui-dropdown", RailsuiDropdown)
        application.register("railsui-modal", RailsuiModal)
        application.register("railsui-range", RailsuiRange)
        application.register("railsui-read-more", RailsuiReadMore)
        application.register("railsui-select-all", RailsuiSelectAll)
        application.register("railsui-tabs", RailsuiTabs)
        application.register("railsui-toast", RailsuiToast)
        application.register("railsui-toggle", RailsuiToggle)
        application.register("railsui-tooltip", RailsuiTooltip)

        // Register theme-specific controllers
        import SelectAllController from "controllers/railsui/select_all_controller"
application.register("select-all", SelectAllController)
import VisibilityController from "controllers/railsui/visibility_controller"
application.register("visibility", VisibilityController)
import PropertiesController from "controllers/railsui/properties_controller"
application.register("properties", PropertiesController)
import SearchController from "controllers/railsui/search_controller"
application.register("search", SearchController)
import InsightChartController from "controllers/railsui/insight_chart_controller"
application.register("insight-chart", InsightChartController)
import HelpSearchController from "controllers/railsui/help_search_controller"
application.register("help-search", HelpSearchController)
import ScrollSpyController from "controllers/railsui/scroll_spy_controller"
application.register("scroll-spy", ScrollSpyController)
import DarkModeController from "controllers/railsui/dark_mode_controller"
application.register("dark-mode", DarkModeController)
import AutoExpandTextAreaController from "controllers/railsui/auto_expand_text_area_controller"
application.register("auto-expand-text-area", AutoExpandTextAreaController)
import InboxController from "controllers/railsui/inbox_controller"
application.register("inbox", InboxController)
import SmoothScrollController from "controllers/railsui/smooth_scroll_controller"
application.register("smooth-scroll", SmoothScrollController)
import GalleryController from "controllers/railsui/gallery_controller"
application.register("gallery", GalleryController)
import InsightsController from "controllers/railsui/insights_controller"
application.register("insights", InsightsController)
import PricingController from "controllers/railsui/pricing_controller"
application.register("pricing", PricingController)
import NavController from "controllers/railsui/nav_controller"
application.register("nav", NavController)
import CounterInputController from "controllers/railsui/counter_input_controller"
application.register("counter-input", CounterInputController)
