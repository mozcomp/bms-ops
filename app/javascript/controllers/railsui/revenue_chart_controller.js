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
          name: "Last year",
          data: [
            224552, 225560, 225446, 226735, 229802, 222510, 254735, 256529,
            257201, 258009, 259029, 253231, 266109, 261024,
          ],
          type: "area",
        },
        {
          name: "Year to date",
          data: [
            223446, 234675, 239802, 240802, 241510, 242735, 245529, 250521,
            263109, 273521, 265109, 265424,
          ],
          type: "area",
        },
      ],
      chart: {
        type: "area",
        sparkline: { enabled: true },
        height: 200,
        background: this.isDarkMode() ? "transparent" : undefined,
        theme: {
          mode: this.isDarkMode() ? "dark" : "light",
        },
      },
      format: "currency",
      dataLabels: {
        enabled: false,
      },
      stroke: {
        curve: "smooth",
        lineCap: "round",
      },
      legend: {
        show: false,
      },
      colors: ["#3b82f6", "#8b5cf6"],
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
      labels: [
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
      ],

      tooltip: {
        shared: true,

        x: {
          show: true,
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
