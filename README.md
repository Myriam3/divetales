# 🤿DiveTales

Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.

# Categories & Species

* **Category** — User-oriented group used to organize species (ex: Shark, Sea Turtles, Nudibranches, ...)
* **Classification** — Biological class for a category (ex: Fish, Reptiles, Mollusks, ...)
* **Species** — Name of the species (ex: Whitetip Reef Shark, Green Sea Turtle, Pikachu nudibranch)
* **Tags** —  Additional characteristics for filtering the species (ex: Pelagic, Reef, ...)

Examples:

```
Fish (class)
 └── Sharks (category)
      └── Oceanic Whitetip Shark (species)
           ├── tropical (tag)
           └── pelagic (tag)
```

```
Fish (class)
 └── Damselfish & Anemonefish (category)
      └── Clownfish (species)
           ├── tropical (tag)
           └── reef (tag)
```

---

## Classification

`Category.classification`

Not already registered class -> `0`

```
 enum :classification, {
    other: 0,
    fish: 1,
    mammal: 2,
    reptile: 3,
    crustacean: 4,
    mollusk: 5,
    cnidarian: 6,
    echinoderm: 7,
    annelid: 8,
    sponge: 8
  }
  ```

## Categories for each class

Not registered category -> `Other`

### 1 - 🐟 Fish

Not already registered fish category -> `Other Fish`

* **🦈Sharks**
* **🦈Rays**
* **🐍Eels**
* **🐴Seahorses & Pipefish** (Syngnathidae family)
* **🐟Gobies & Blennies**
* **🐟Groupers**
* **🐠Wrasses**
* **🐟Lionfish & Scorpionfish** (Scorpaenoidei)
* **🐟Triggerfish & Filefish** (Balistoidei)
* **🐡Pufferfish & Porcupinefish** (Tetraodontoidei)
* **🐠Damselfish & Anemonefish** (Pomacentridae family)
* **🐠Parrotfish**
* **🐠Angelfish & Butterflyfish**
* **🐟Pelagic Fish** — tuna, mackerel, sardines, trevally, flying fish, sunfish, barracuda, etc.
* **Other Fish**

---

### 2 - 🐋 Mammals

* **🐋Whales**
* **🐬Dolphins & Orcas**
* **🦭Seals & Sea Lions**
* **🦦Sea Otters**
* **🦭Manatees & Dugongs**

---

### 3 - 🐢 Reptiles

* **🐢Sea Turtles**
* **🐍Sea Snakes**
* **🦎Marine Iguanas & Crocodiles**

---

### 4 - 🦐 Crustaceans

* **🦐Shrimps**
* **🦐Mantis Shrimps**
* **🦀Crabs**
* **🦞Lobsters**
* **Other Crustaceans**

---

### 5 - 🐙 Mollusks

* **🐌Nudibranchs** (Gastropods)
* **🐌Sea Hares** (Gastropods)
* **🐌Sea Snails** (Gastropods)
* **🐙Octopuses** (Cephalopods)
* **🦑Squids** (Cephalopods)
* **🦑Cuttlefish** (Cephalopods)
* **🐚Clams**
* **Other Mollusks**

### 6 - 🪼 Cnidarians

* **🪼Jellyfish**
* **🪸Corals**
* **🪸Sea Anemones**
* **🪼Siphonophores**
* **🪸Hydroids**
* **🪸Sea Pens**

---

### 7 - ⭐ Echinoderms

* **⭐Stars**
* **🦔Sea Urchins**
* **🥒Sea Cucumbers**
* **🌿Crinoids**

### 8 - 🪱 Annelids

* **🪱Bristle Worms**
* **🪱Tubeworms**
* **Other Annelids**

### 9 - 🧽 Sponges

* **🪸Tube Sponges**
* **🪨Barrel Sponges**
* **🧽Encrusting Sponges**
