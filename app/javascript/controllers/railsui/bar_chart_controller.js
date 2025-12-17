import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

export default class extends Controller {
  static values = {
    name: String,
    data: Array,
    yAxisMin: Number,
    default: 0,
    xAxisMax: { type: Number, default: 10 },
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
      colors: ["#0d6efd"],
      chart: {
        toolbar: false,
        type: "bar",
        height: 400,
        background: "transparent",
        zoom: { enabled: false },

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
        min: 0,
        max: this.xAxisMaxValue,
        tickAmount: this.xAxisMaxValue,
        labels: {
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
              return `${value.toFixed(0)}${this.yAxisDenominationValue}`
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
      plotOptions: {
        bar: {
          borderRadius: 6,
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
