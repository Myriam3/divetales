import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl';

export default class extends Controller {
  static targets = [
    "mapContainer",
    "coordinatesContainer",
    "mapInfoContainer"
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
    this.setMap(this.latitudeValue, this.longitudeValue, settings);
  }

  async initNew(e = {}) {
    if (this.isInit) return;

    const settings = await this.getMapboxInfo();
    if (!settings.token) return;
    this.setMap(e.detail.lat, e.detail.long, settings);
    // TODO update map & info when re-upload fit file or change coordinates
    this.isInit = true;
  }

  setMap(lat, long, settings) {
    if (!(lat && long)) return;
    this.initMap(lat, long, settings);
    this.setGeoInfo(lat, long, settings.token);
  }

  getMapboxInfo() {
    return fetch(this.apiUrlValue, {
      headers: {
        'X-CSRF-Token': this.getCsrfToken()
      }
    })
    .then(res => res.json())
    .then(data => data)
    .catch(error => console.error("Mapbox:", error));
  }

  initMap(lat, long, { token, style}) {
    mapboxgl.accessToken = token;
    this.map = new mapboxgl.Map({
      container: this.mapContainerTarget,
      style: style,
      center: [long, lat],
      zoom: 8
    });


    this.map._container.style.display = 'block';

     // Marker
    window.setTimeout(() => {
    new mapboxgl.Marker()
      .setLngLat([long, lat])
      //.setPopup(new mapboxgl.Popup().setHTML("Here!"))
      .addTo(this.map);
    }, 500);

  }

  async fetchGeocodingPlace(lat, long, token) {
    try {
      const response = await fetch(
        `https://api.mapbox.com/geocoding/v5/mapbox.places/${long},${lat}.json?access_token=${token}&language=en&types=place`
      );
      const data = await response.json();
      console.log(data);
      if (data.features && data.features[0]) {
        return data.features[0].place_name
      }
    } catch (error) {
      console.error(error);
    }
  }

  async setGeoInfo(lat, long, token) {
    if (this.coordinatesContainerTarget) {
      this.coordinatesContainerTarget.insertAdjacentHTML('beforeend', `${lat}, ${long}`);
      this.coordinatesContainerTarget.style.display = 'block';
    }

    const geoInfo = await this.fetchGeocodingPlace(lat, long, token);

    if (!geoInfo || !this.mapInfoContainerTarget) return;

    this.dispatch("geoinfo", {
      detail: geoInfo,
      bubbles: true
    });

    this.mapInfoContainerTarget.insertAdjacentHTML('beforeend', geoInfo.replace(/<[^>]*>/g, ''));
    this.mapInfoContainerTarget.style.display = 'block';
  }

  getCsrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content;
  }

  disconnect() {
    if (this.map) this.map.remove();
  }
}
