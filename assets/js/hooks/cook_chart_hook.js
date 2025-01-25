import Chart from "chart.js/auto";
import "chartjs-adapter-date-fns";

const CookChartHook = {
  mounted() {
    this.createChart();
  },

  updated() {
    if (this.chart) {
      this.chart.destroy();
    }
    this.createChart();
  },

  destroyed() {
    if (this.chart) {
      this.chart.destroy();
    }
  },

  chartDatasets(dataset) {
    return {
      setTempData: dataset.map((d) => ({
        x: new Date(d.timestamp),
        y: d.set_temp,
      })),
      blowerData: dataset.map((d) => ({
        x: new Date(d.timestamp),
        y: d.blower,
      })),
      pit1Data: dataset.map((d) => ({
        x: new Date(d.timestamp),
        y: d.temps.pit_1,
      })),
      pit2Data: dataset.map((d) => ({
        x: new Date(d.timestamp),
        y: d.temps.pit_2,
      })),
      meat1Data: dataset.map((d) => ({
        x: new Date(d.timestamp),
        y: d.temps.meat_1,
      })),
      meat2Data: dataset.map((d) => ({
        x: new Date(d.timestamp),
        y: d.temps.meat_2,
      })),
    };
  },

  createChart() {
    const ctx = this.el.getContext("2d");
    const dataset = JSON.parse(this.el.getAttribute("dataset"));
    const ds = this.chartDatasets(dataset);
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        datasets: [
          {
            label: "Set Temperature",
            data: ds.setTempData,
            borderColor: "rgb(255, 0, 0)",
            backgroundColor: "rgb(255, 0, 0)",
            tension: 0.1,
            yAxisID: "temp",
          },
          {
            label: "Blower %",
            data: ds.blowerData,
            borderColor: "rgb(75, 192, 192)",
            backgroundColor: "rgb(75, 192, 192)",
            tension: 0.1,
            yAxisID: "percent",
          },
          {
            label: "Pit 1",
            data: ds.pit1Data,
            borderColor: "rgb(139, 0, 0)", // dark red
            backgroundColor: "rgb(139, 0, 0)",
            tension: 0.1,
            yAxisID: "temp",
          },
          {
            label: "Pit 2",
            data: ds.pit2Data,
            borderColor: "rgb(165, 42, 42)", // brown-red
            backgroundColor: "rgb(165, 42, 42)",
            tension: 0.1,
            yAxisID: "temp",
          },
          {
            label: "Meat 1",
            data: ds.meat1Data,
            borderColor: "rgb(205, 92, 92)", // indian red
            backgroundColor: "rgb(205, 92, 92)",
            tension: 0.1,
            yAxisID: "temp",
          },
          {
            label: "Meat 2",
            data: ds.meat2Data,
            borderColor: "rgb(240, 128, 128)", // light coral
            backgroundColor: "rgb(240, 128, 128)",
            tension: 0.1,
            yAxisID: "temp",
          },
        ],
      },
      options: {
        responsive: true,
        animation: {
          duration: 0,
        },
        transitions: {
          active: {
            animation: {
              duration: 0,
            },
          },
        },
        plugins: {
          legend: {
            display: true,
            position: "bottom",
          },
        },
        scales: {
          x: {
            type: "time",
            time: { unit: "hour" },
            title: {
              display: true,
              text: "Time",
            },
          },
          temp: {
            type: "linear",
            position: "left",
            title: {
              display: true,
              text: "Temperature °F",
            },
          },
          percent: {
            type: "linear",
            position: "right",
            min: 0,
            max: 100,
            title: {
              display: true,
              text: "Blower %",
            },
          },
        },
      },
    });
  },
};

export default CookChartHook;
