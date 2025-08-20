package com.example.incident_service.controller;
import com.example.incident_service.model.Incident;
import com.example.incident_service.service.IncidentService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/incidents")
public class IncidentController {
    private final IncidentService service;

    public IncidentController(IncidentService service) {
        this.service = service;
    }

    @GetMapping
    public List<Incident> getAllIncidents() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public Incident getIncident(@PathVariable Long id) {
        return service.getById(id);
    }

    @PostMapping
    public Incident createIncident(@RequestBody Incident incident) {
        return service.create(incident);
    }

    @PutMapping("/{id}")
    public Incident updateIncident(@PathVariable Long id, @RequestBody Incident incident) {
        return service.update(id, incident);
    }

    @DeleteMapping("/{id}")
    public void deleteIncident(@PathVariable Long id) {
        service.delete(id);
    }
}

