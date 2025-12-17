import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

export default class extends Controller {
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
          name: "Gross MRR",
          data: [
            82234, 82059, 83958, 84300, 84500, 85560, 85000, 85000, 87505,
            89000, 94352,
          ],
          type: "area",
        },
      ],
      colors: ["#0d6efd"],
      chart: {
        sparkline: { enabled: true },
        toolbar: false,
        height: 200,
        type: "area",
        background: this.isDarkMode() ? "transparent" : undefined,
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
      yaxis: {
        labels: {
          formatter: function (value) {
            return value.toLocaleString("en-US", {
              style: "currency",
              currency: "USD",
              minimumFractionDigits: 0,
            })
          },
        },
      },
      xaxis: {
        type: "datetime",
        categories: [
          "May 5, 2023",
          "May 8, 2023",
          "May 11, 2023",
          "May 15, 2023",
          "May 17, 2023",
          "May 19, 2023",
          "May 21, 2023",
          "May 23, 2023",
          "May 25, 2023",
          "May 27, 2023",
          "June 3, 2023",
        ],
      },
      tooltip: {
        x: {
          format: "dd/MM/yy",
        },
      },
    }

    this.chart = new ApexCharts(this.element, options)
    this.chart.render()
  }

  updateChartTheme() {
    const newTheme = this.isDarkMode() ? "dark" : "light"
    if (this.chart) {
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
