# Mapping Global Lending Networks  
**Social Network Analysis Final Project | Fall 2024**  
*Analyzing IMF, World Bank, and bilateral lending relationships using graph theory and geographic visualization.*  

**Authors**: Aisha Abdul Qadir, Sara Baloch, Madiha Qasmi  
**Course**: CS/SDP 361/352

### **Background & Objectives**  
- **Focus**: Compare borrowing behaviors (Global North vs. South), identify regional lending trends, and analyze financial clusters.  
- **Goal**: Map lending relationships (IMF, World Bank, nations) to uncover economic interdependencies.  

### **Key Findings**  
- **Network Density**: 0.22 (sparse, regionally concentrated loans).  
- Norway/Germany have **zero in-degree** (no borrowing).  
- Saudi Arabia lends **strategically to South Asia**.  
- Argentina is the **top IMF borrower**.
- Low clustering, implying that loans are globally dispersed and not regionally concentrated.
 
- **Top Centralities (Table)**:  
  - **Betweenness**: China, India, Iraq (key bridges).  
  - **Out-Degree**: France, Kuwait, China (top lenders).  
  - **In-Degree**: Sudan, Congo, Iraq (top borrowers).  

**Tools**: Python (Pandas, NetworkX), R, Gephi  

---

## Repository Structure  
```bash
├── csv_files/  
│   ├── raw/                                # Raw datasets (IMF, WorldBank, bilateral loans)  
│   │   ├── imf.xlsx                        # IMF loans in SDRs  
│   │   ├── worldbank and imf.xlsx          # Combined WB/IMF data  
│   │   └── initial_country_to_country.csv  # Bilateral loans (scraped via R API)  
│   └── final/                              # Processed data  
│       ├── edges.csv                       # Directed lender→borrower relationships (weighted by USD)  
│       ├── nodes.csv                       # Countries/institutions with lat/long  
│       └── results_for_analysis/  
│           └── network_metrics.csv         # Centrality, clustering, degree  
│  
├── scripts_python_and_R/  
│   ├── for_merging_and_converting.py       # Currency conversion (SDR→USD), name standardization  
│   ├── country_to_country.R                # API scraping for bilateral loans  
│   └── network_analysis.R                  # Centrality calculations, ER/BA/WS model comparisons  
│  
├── visualisations/  
│   ├── initial/                            # Early Gephi graphs (exploratory)  
│   └── geographic/                         # Final maps  
│       ├── mappp.jpeg                      # Geographic network plot  
│       ├── [in/out]_degree.gephi           # Gephi files for centrality visualizations  
│       └── updated.gephi                   # Final annotated network  
│
├── Final_Poster.pdf                        # Contains a good summary of findings
└── Final_Paper.pdf                         # Full paper (methodology, results, references)  
```

For details, see the full paper: [Final_Paper.pdf](Final_Paper.pdf).  
