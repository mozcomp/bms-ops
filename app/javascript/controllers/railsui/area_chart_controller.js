import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

export default class extends Controller {
  static values = {
    name: String,
    data: Array,
    yAxisMin: Number,
    default: 0,
    yAxisMax: { type: Number, default: 100 },
    yAxisDenomination: { type: String, default: "%" },
  }

  connect() {
    // Add an event listener for changes in color scheme if theme switch
    window.matchMedia("(prefers-color-scheme: dark)").addListener(() => {
      this.initializeChart()
      this.updateChartTheme()
    })

    // Initial setup
    this.initializeChart()
    this.updateChartTheme()
  }

  initializeChart() {
    const options = {
      series: [
        {
          name: this.nameValue,
          data: this.dataValue,
        },
      ],
      colors: ["#0d6efd", "#062C65"],
      chart: {
        toolbar: false,
        height: 440,
        type: "area",
        background: "transparent",
        // Add the theme property
        theme: {
          mode: this.isDarkMode() ? "dark" : "light",
        },
      },
      dataLabels: {
        enabled: false,
      },
      stroke: {
        curve: "smooth",
      },
      xaxis: {
        type: "datetime",
        tickAmount: 10,
        labels: {
          formatter: function (value, timestamp, opts) {
            return opts.dateFormatter(new Date(timestamp), "dd MMM")
          },
          style: {
            fontSize: 14,
          },
        },
        axisTicks: {
          show: false,
        },
        axisBorder: {
          show: false,
        },
      },

      yaxis: {
        min: 0,
        max: this.yAxisMaxValue,
        tickAmount: 5,
        labels: {
          formatter: (value) => {
            if (this.yAxisDenominationValue === "%") {
              // Format as percentage
              return `${value.toFixed(2)}${this.yAxisDenominationValue}`
            } else if (this.yAxisDenominationValue === "$") {
              // Format as currency
              return `${value.toLocaleString("en-US", {
                style: "currency",
                currency: "USD",
              })}`
            } else {
              // Default case, render with the provided denomination
              return `${value}${this.yAxisDenominationValue}`
            }
          },
          style: {
            fontSize: 14,
          },
        },
      },
      tooltip: {
        x: {
          title: {
            formatter: (value) => {
              if (this.yAxisDenominationValue === "%") {
                // Format as percentage
                return `${value.toFixed(2)}${this.yAxisDenominationValue}`
              } else if (this.yAxisDenominationValue === "$") {
                // Format as currency
                return `${this.yAxisDenominationValue}${value.toLocaleString(
                  "en-US",
                  {
                    style: "currency",
                    currency: "USD",
                  }
                )}`
              } else {
                // Default case, render with the provided denomination
                return `${value.toFixed(2)}${this.yAxisDenominationValue}`
              }
            },
          },
        },
        marker: {
          show: false,
        },
      },
      grid: {
        show: false,
      },
    }

    this.chart = new ApexCharts(this.element, options)
    this.chart.render()
  }

  updateChartTheme() {
    if (this.chart) {
      const newTheme = this.isDarkMode() ? "dark" : "light"
      this.chart.updateOptions({
        theme: {
          mode: newTheme,
        },
      })
    }
  }

  isDarkMode() {
    return (
      window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)").matches
    )
  }
}
