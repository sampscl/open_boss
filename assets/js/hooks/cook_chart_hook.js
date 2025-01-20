import Chart from 'chart.js/auto'
import 'chartjs-adapter-date-fns'

const CookChartHook = {
  chartDatasets(dataset) {
    return ({
      setTempData: dataset.map(d => ({x: new Date(d.timestamp), y: d.set_temp}) ),
      blowerData: dataset.map(d => ({x: new Date(d.timestamp), y: d.blower}) ),
      pit1Data: dataset.map(d => ({x: new Date(d.timestamp), y: d.temps.pit_1}) ),
      pit2Data: dataset.map(d => ({x: new Date(d.timestamp), y: d.temps.pit_2}) ),
      meat1Data: dataset.map(d => ({x: new Date(d.timestamp), y: d.temps.meat_1}) ),
      meat2Data: dataset.map(d => ({x: new Date(d.timestamp), y: d.temps.meat_2}) ),
    })
  },
  
  mounted() {
    const ctx = this.el.getContext('2d')
    const dataset = JSON.parse(this.el.getAttribute("dataset"))

    const ds = this.chartDatasets(dataset)
    new Chart(ctx, {
      type: 'line',
      data: {
        datasets: [
          {
          label: "Set Temperature",
          data: ds.setTempData,
          borderColor:'rgb(255, 99, 132)',
          backgroundColor: 'rgb(255, 99, 132)',
          tension: 0.1,
          yAxisID: 'temp'
        },
        {
          label: "Blower %",
          data: ds.blowerData,
          borderColor: 'rgb(75, 192, 192)',
          backgroundColor: 'rgb(75, 192, 192)',
          tension: 0.1,
          yAxisID: 'percent'
        },
        {
          label: "Pit 1",
          data: ds.pit1Data,
          borderColor:'rgb(255, 99, 132)',
          backgroundColor: 'rgb(255, 99, 132)',
          tension: 0.1,
          yAxisID: 'temp'
        },
        {
          label: "Pit 2",
          data: ds.pit2Data,
          borderColor:'rgb(255, 99, 132)',
          backgroundColor: 'rgb(255, 99, 132)',
          tension: 0.1,
          yAxisID: 'temp'
        },
        {
          label: "Meat 1",
          data: ds.meat1Data,
          borderColor:'rgb(255, 99, 132)',
          backgroundColor: 'rgb(255, 99, 132)',
          tension: 0.1,
          yAxisID: 'temp'
        },
        {
          label: "Meat 2",
          data: ds.meat2Data,
          borderColor:'rgb(255, 99, 132)',
          backgroundColor: 'rgb(255, 99, 132)',
          tension: 0.1,
          yAxisID: 'temp'
        }
      ]
      },
      options: {
        responsive: true,
        plugins: { 
          legend: { 
            display: true, 
            position: "bottom" 
          } 
        },
        scales: {
          x: {
            type: 'time',
            time: { unit: 'hour' },
            title: {
              display: true,
              text: 'Time'
            }
          },
          temp: { 
            type: 'linear',
            position: 'left',
            title: {
              display: true,
              text: 'Temperature °F'
            }
          },
          percent: { 
            type: 'linear', 
            position: "right", 
            min: 0, 
            max: 100,
            title: {
              display: true,
              text: 'Blower %'
            }
          }
        }
      }
    })
  }
}

export default CookChartHook