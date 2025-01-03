import Chart from 'chart.js/auto'

const CookChartHook = {
  mounted() {
    const ctx = this.el.getContext('2d')
    const data = JSON.parse(this.el.dataset.cook_history)
    
    new Chart(ctx, {
      type: 'line',
      data: {
        datasets: [{
          data: data.map(d => ({x: d.timestamp, y: d.set_temp})),
          borderColor: 'rgb(75, 192, 192)',
          tension: 0.1
        }]
      },
      options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
          x: { type: 'time', time: { unit: 'minute' } }
        }
      }
    })
  }
}

export default CookChartHook