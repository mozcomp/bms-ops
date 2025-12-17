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
        import RevenueChartController from "controllers/railsui/revenue_chart_controller"
application.register("revenue-chart", RevenueChartController)
import ListGridController from "controllers/railsui/list_grid_controller"
application.register("list-grid", ListGridController)
import DarkModeController from "controllers/railsui/dark_mode_controller"
application.register("dark-mode", DarkModeController)
import BarChartController from "controllers/railsui/bar_chart_controller"
application.register("bar-chart", BarChartController)
import AreaChartController from "controllers/railsui/area_chart_controller"
application.register("area-chart", AreaChartController)
import PricingController from "controllers/railsui/pricing_controller"
application.register("pricing", PricingController)
import MrrChartController from "controllers/railsui/mrr_chart_controller"
application.register("mrr-chart", MrrChartController)
