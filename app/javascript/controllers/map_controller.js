import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl';

export default class extends Controller {
  static targets = [
    "mapContainer",
    "coordinatesContainer",
    "mapInfoContainer",
    "mapCanvas",
    "memoryDiveContainer",
    "itinaryBtn",
    "itineraryLocationWrapper",
    "itineraryLocation"
  ];

  static values = {
    apiUrl: String,
    latitude: String,
    longitude: String,
    tripId: String,
    dives: Array,
    diveUrl: String
  };

  connect() {
    this.currentDive = null;
    this.points = {};
    this.init();
  }

  async init() {
    const settings = await this.getMapboxInfo();
    if (!settings?.token) return;

    // Trip map
    if (this.divesValue?.length) {
      this.initTripMap(settings);
      return;
    }

     // Dive map
    if (!(this.latitudeValue && this.longitudeValue)) return;
    this.initMapbox(this.latitudeValue, this.longitudeValue, settings);
  }

  // New dive form
  async initNew(e = {}) {
    if (this.isInit) return;

    const settings = await this.getMapboxInfo();
    if (!settings.token) return;
    this.initMapbox(e.detail.lat, e.detail.long, settings);
    // TODO update map & info when re-upload fit file or change coordinates
    this.isInit = true;
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

  initMapbox(lat, long, settings) {
    if (!(lat && long)) return;
    this.displayMap([long, lat], 8, settings);
    this.setGeoInfo(lat, long, 8, settings.token);
  }

  // Trip Map
  initTripMap(settings) {
    const centerOptions = this.getDivesBounds(this.divesValue);
    this.displayMap(centerOptions.center, 6, settings, centerOptions.bounds);
  }

  // Display map
  displayMap(center, zoom, { token }, bounds = null) {
    mapboxgl.accessToken = token;
    const options = {
      container: this.mapCanvasTarget,
      style: "mapbox://styles/mapbox/streets-v12",
      center,
      projection: "mercator",
      renderWorldCopies: false,
      minZoom: 2,
      zoom
    }

    if (!this.divesValue.length) options.minZoom = 4;

    this.map = new mapboxgl.Map(options);
    if (bounds) {
      window.setTimeout(() => {
        try {
          this.map.fitBounds(bounds, {
            padding: 50
          });
        } catch (error) {
          console.log(error);
        }
      }, 500);
    }

    this.mapContainerTarget.style.visibility = 'visible';
    this.mapContainerTarget.style.height = 'auto';

    // Dive map
    if (!this.divesValue.length) {
      window.setTimeout(() => {
        this.addDiveMarker(lat, long);
      }, 500);

      return;
    }

    // Trip map
    this.addTripMarkers();

    this.itinaryBtnTargets.forEach((btn) => {
      const locationId = btn.getAttribute('data-location');
      if (!locationId) return;

      const locationDives = this.divesValue.filter((item) => item.location_id === Number(locationId));
      if (!locationDives.length) return;
      const centerOptions = this.getDivesBounds(locationDives);

      btn.addEventListener('click', (e) => {
        this.centerMap(e, btn, centerOptions.center, centerOptions.bounds);
      });
    });
  }

  // Markers
  addDiveMarker(lat, long) {
    try {
      const marker = new mapboxgl.Marker()
        .setLngLat([long, lat])
        .addTo(this.map);
      return marker;
    } catch(error) {
      console.log(error);
    }
  }

  addTripMarkers() {
    // Group dives by coordinates
    this.points = this.divesValue.reduce((acc, dive) => {
      const key = `${dive.lat},${dive.long}`;
      if (!acc[key]) acc[key] = [];
      acc[key].push(dive);
      return acc;
    }, {});

    const setMarker = (point) => {
      const marker = this.addDiveMarker(point[0].lat, point[0].long);

      if (!marker) return;

      // Click on marker handler
      marker?.getElement().addEventListener('click', (e) => {
        this.displayDive(point[0]);
      });
    }

    for (const key in this.points) {
      setMarker(this.points[key]);
    }
  }

  // Display dive on marker click
  async displayDive(dive) {
    const url = new URL(this.diveUrlValue, window.location.origin);
    url.searchParams.set("dive_id", dive.id);

    try {
      const response = await fetch(url, {
        headers: { Accept: "text/vnd.turbo-stream.html" },
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      });
      const html = await response.text();
      Turbo.renderStreamMessage(html);
      this.currentDive = dive;

      //if (pointDives.length > 1) this.pointDivesToRender = pointDives

    } catch (error) {
      console.log(error);
    }
  }

  displayPointDives(dives) {
    if (!this.itineraryLocationTarget) return;

    if (this.itineraryLocationWrapperTarget) {
      this.itineraryLocationWrapperTarget.style.display = 'block';
    }

    dives.forEach((dive, index) => {
      const radio = this.createPointDiveRadio(dive, index);
      this.itineraryLocationTarget.appendChild(radio);

      radio.addEventListener('change', (e) => {
        const newDive = this.divesValue.find((dive) => dive.id === Number(e.target.value));
        if (newDive) this.displayDive(newDive);
      });
    });
  }

  itineraryLocationTargetConnected() {
    if (!this.points || !this.currentDive) return;
    const coordinatesKey = `${this.currentDive.lat},${this.currentDive.long}`;
    const currentPoint = this.points[coordinatesKey];

    if (currentPoint.length > 1) {
      this.displayPointDives(currentPoint);
    }
  }

  createPointDiveRadio(dive, index) {
      const name = "itineraryPointDive";
      const id = `${name}-${index + 1}`;
      const parent = document.createElement('div');
      const label = document.createElement('label');
      let labelText = '';
      const radio = document.createElement('input');
      parent.classList.add('form-check','form-check-inline');
      label.classList.add('form-check-label');
      radio.classList.add('form-check-input');
      radio.type = 'radio';
      radio.id = id;
      radio.name = name;
      label.setAttribute('for', id);
      radio.value = dive.id;
      if (this.currentDive.id === dive.id) radio.checked = true;

      if (dive.number) labelText += `#${dive.number} `;
      labelText += dive.date;
      if (dive.start_time) labelText += dive.start_time;

      label.textContent = labelText;
      parent.appendChild(radio);
      parent.appendChild(label);

      return parent;
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

    this.mapInfoContainerTarget.insertAdjacentHTML('beforeend', geoInfo.name);
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
      if (!data.features.length) return;

      const result = data.features[0].properties;

      return {
        name: `${result.full_address?.replace(/<[^>]*>/g, '')}`,
        countryCode: result.context?.country?.country_code?.toLowerCase()
      };
    } catch (error) {
      console.error('Mapbox Geocoding', error);
    }
  }

  // Center map on itinerary click
  centerMap(e, btn, center, bounds = null) {
    e.preventDefault();
    try {
      if (bounds) {
        this.map.fitBounds(bounds, {
          maxZoom: 10,
        });
      } else {
        this.map.flyTo({
          center,
          zoom: 11
        });
      }

      // Toggle current location
      if (this.currentLocation) this.currentLocation.style.border = '0';
      btn.style.border = 'solid 2px red';
      this.currentLocation = btn;
    } catch (error) {
      console.log(error);
    }
  }

  // Set location bounds with dives
  getDivesBounds(dives) {
    const bounds = new mapboxgl.LngLatBounds();
    let startLat = 0;
    let startLong = 0;

    dives.forEach((dive) => {
      if (!(dive.lat && dive.long)) return;
      bounds.extend([dive.long, dive.lat]);

      if (!(startLat && startLong)) {
        startLat = dive.lat;
        startLong = dive.long;
      }
    });

    return {
      center: [startLong, startLat],
      bounds
    }
  }

  disconnect() {
    //if (this.map) this.map.remove();
  }
}
