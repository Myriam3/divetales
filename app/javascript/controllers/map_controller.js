import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl';

export default class extends Controller {
  static targets = [
    "mapContainer",
    "coordinatesContainer",
    "mapInfoContainer",
    "mapCanvas"
  ];

  static values = {
    apiUrl: String,
    latitude: String,
    longitude: String
  };

  connect() {
    this.init();
  }

  async init() {
    if (!(this.latitudeValue && this.longitudeValue)) return;
    const settings = await this.getMapboxInfo();
    if (!settings.token) return;
    this.initMapbox(this.latitudeValue, this.longitudeValue, settings);
  }

  async initNew(e = {}) {
    if (this.isInit) return;

    const settings = await this.getMapboxInfo();
    if (!settings.token) return;
    this.initMapbox(e.detail.lat, e.detail.long, settings);
    // TODO update map & info when re-upload fit file or change coordinates
    this.isInit = true;
  }

  initMapbox(lat, long, settings) {
    if (!(lat && long)) return;
    this.displayMap(lat, long, settings);
    this.setGeoInfo(lat, long, settings.token);
  }

  async getMapboxInfo() {
    return fetch(this.apiUrlValue, {
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
      }
    })
    .then(res => res.json())
    .then(data => data)
    .catch(error => console.error("Mapbox:", error));
  }

  // Display map
  displayMap(lat, long, { token }) {
    mapboxgl.accessToken = token;
    this.map = new mapboxgl.Map({
      container: this.mapCanvasTarget,
      style: "mapbox://styles/mapbox/streets-v12",
      center: [long, lat],
      zoom: 8,
      minZoom: 4
    });

    this.mapContainerTarget.style.visibility = 'visible';
    this.mapContainerTarget.style.height = 'auto';
    //this.map._container.style.display = 'block';

    // Marker
    window.setTimeout(() => {
    new mapboxgl.Marker()
      .setLngLat([long, lat])
      //.setPopup(new mapboxgl.Popup().setHTML("Here!"))
      .addTo(this.map);
    }, 500);
  }

  // Geocoding info
  async setGeoInfo(lat, long, token) {
    // Display coordinates
    if (this.coordinatesContainerTarget) {
      this.coordinatesContainerTarget.insertAdjacentHTML('beforeend', `${lat}, ${long}`);
      this.coordinatesContainerTarget.style.display = 'block';
    }

    // Display geo info
    const geoInfo = await this.fetchGeocodingPlace(lat, long, token);
    if (!geoInfo || !this.mapInfoContainerTarget) return;

    this.mapInfoContainerTarget.insertAdjacentHTML('beforeend', geoInfo.replace(/<[^>]*>/g, ''));
    this.mapInfoContainerTarget.style.display = 'block';

    // Event for updating the form
    this.dispatch("geoinfo", {
      detail: geoInfo,
      bubbles: true
    });
  }

  async fetchGeocodingPlace(lat, long, token) {
    try {
      const endpoint = `https://api.mapbox.com/search/geocode/v6/reverse?longitude=${long}&latitude=${lat}&language=en&limit=1&access_token=${token}`
      const response = await fetch(endpoint);
      const data = await response.json();
      // console.log('GEOINFO', data);
      if (!data.features.length) return;

      const result = data.features[0].properties;
      return `${result.full_address}`;
    } catch (error) {
      console.error('Mapbox Geocoding', error);
    }
  }

  disconnect() {
    if (this.map) this.map.remove();
  }
}
