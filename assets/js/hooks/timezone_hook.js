const TimezoneInput = {
  mounted() {
    this.el.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
    this.pushEvent("set_timezone", { timezone: this.el.value });
    
  }
}
export default TimezoneInput;