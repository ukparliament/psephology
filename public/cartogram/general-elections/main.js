"use strict";
const electionId = window.location.pathname.split("/")[2];
const geoJsonUrl = "/cartogram/general-elections/" + electionId + ".geojson";

const map = L.map('map')
    .setView([51.505, -0.09], 13);
if (parseInt(electionId) >= 6 && parseInt(electionId) != 7) {
    const attribution = 'Hex shapes provided by <a href="https://automaticknowledge.co.uk">Automatic Knowledge</a>';
    map.attributionControl.addAttribution(attribution);
}
else {
    const attribution = 'Hex shapes provided by <a href="https://open-innovations.org/">Open Innovations</a>';
    map.attributionControl.addAttribution(attribution);
}
const partyColours = {
    Con: "#00539f",
    Lab: "#d50000",
    SDLP: "#4ea268",
    LD: "#fc7d0b",
    UKIP: "#722889",
    Green: "#78b82a",
    SNP: "#fff685",
    DUP: "#d46a4c",
    UUP: "#a1cdf0",
    APNI: "#cdaf2d",
    PC: "#348837",
    SF: "#02665f",
    Spk: "#909090",
    Brexit: "#12b6cf",
    Ind: "#909090",
    TUV: "#0c3a6a",
    RUK: "#12b6cf",
    Alliance: "#cdaf2d",
    // need proper colours
    Other: "#909090",
    BNP: "purple",
    Res: "#909090",
    KHHC: "#909090",
    SSP: "#909090"
};
function getPartyColour(abbrev) { return partyColours[abbrev]; }
async function getHexData(url) {
    const res = await fetch(url);
    if (!res.ok)
        throw new Error("Failed to fetch: $res.status");
    return res.json();
}
function generateTooltip(feature) {
    if (feature.properties["Election result summary"] === null) {
        return feature.properties.constituency_name + "<br>" + feature.properties["Main party name"];
    }
    else {
        return feature.properties.constituency_name + "<br>" + feature.properties["Election result summary"];
    }
}
;
let currentMapMode = "Wins";
function getFillColour(partyAbbreviation, resultText) {
    if (currentMapMode === "Wins") {
        return partyColours[partyAbbreviation];
    }
    else {
        if (resultText.includes("gain")) {
            return partyColours[partyAbbreviation];
        }
        else {
            return "#FFFFFF";
        }
    }
}
function styleHex(feature) {
    const partyAbbrev = feature?.properties["Main party abbreviation"];
    const result = feature?.properties["Election result summary"] ?? "";
    return {
        fillColor: getFillColour(partyAbbrev ?? "None", result) ?? "#909090",
        // fillColor: getPartyColour(partyAbbrev ?? "None") ?? "#909090",
        fillOpacity: 1,
        opacity: 1,
        color: "#555555",
        weight: 0.8
    };
}
const WinGainControl = L.Control.extend({
    onAdd: function () {
        const container = L.DomUtil.create('div', 'leaflet-bar colour-toggle-control');
        container.style.background = "white";
        container.style.padding = "6px 8px";
        container.innerHTML = `
      <label style="display:block;"><input type="radio" name="mapMode" value="Wins" checked> Wins</label>
      <label style="display:block;"><input type="radio" name="mapMode" value="Gains"> Gains</label>
    `;
        L.DomEvent.disableClickPropagation(container);
        container.querySelectorAll('input[name="mapMode"]')
            .forEach(radio => {
            radio.addEventListener('change', (e) => {
                currentMapMode = e.target.value;
                map.eachLayer((layer) => {
                    if (layer instanceof L.GeoJSON) {
                        layer.setStyle(styleHex);
                    }
                });
            });
        });
        return container;
    }
});
if (electionId != "5" && electionId != "7") {
    new WinGainControl({ position: "topleft" }).addTo(map);
}
getHexData(geoJsonUrl).then(data => {
    const layer = L.geoJson(data, {
        style: styleHex,
        onEachFeature: (feature, layer) => {
            layer.bindTooltip(generateTooltip(feature), {
                sticky: true,
                direction: "top",
                className: "hex-tooltip"
            });
            layer.on("click", () => {
                const url = feature.properties["Election URL"];
                // window.open(url, "_blank");
                layer.closeTooltip();
                if (layer instanceof L.GeoJSON) {
                    layer.setStyle(styleHex);
                }
                window.location.href = url;
            });
            layer.on("mouseover", (e => {
                const thisHex = e.target;
                thisHex.setStyle({
                    weight: 2,
                    color: "#FFFFFF"
                });
            }));
            layer.on("mouseout", (e) => {
                const thisHex = e.target;
                thisHex.setStyle({
                    weight: 0.8,
                    color: "#555555"
                });
            });
        }
    }).addTo(map);
    map.fitBounds(layer.getBounds());
});
