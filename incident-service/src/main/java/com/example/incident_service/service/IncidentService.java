package com.example.incident_service.service;
import com.example.incident_service.model.Incident;
import com.example.incident_service.repository.IncidentRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class IncidentService {
    private final IncidentRepository repository;

    public IncidentService(IncidentRepository repository) {
        this.repository = repository;
    }

    public List<Incident> getAll() {
        return repository.findAll();
    }

    public Incident getById(Long id) {
        return repository.findById(id).orElse(null);
    }

    public Incident create(Incident incident) {
        return repository.save(incident);
    }

    public Incident update(Long id, Incident details) {
        Incident incident = repository.findById(id).orElseThrow();
        incident.setTitle(details.getTitle());
        incident.setSeverity(details.getSeverity());
        incident.setStatus(details.getStatus());
        incident.setAssignedTo(details.getAssignedTo());
        return repository.save(incident);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}

