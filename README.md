# COSC 421 - Network Science Final Project

This project was created for the COSC 421 (Network Science) course at UBC Okanagan. It explores social network structures using Natural Language Processing (NLP) to extract relationships from job description datasets (textual data) and builds network graphs to analyze interactions and patterns.

## 📌 Project Overview

We used a dataset of 12,000+ job descriptions from Feb 2019 onwards to identify trends in programming languages versatility and co-occurrence patterns in job descriptions and their relationships using NLP techniques. These relationships were then modeled as a network to explore structural properties such as centrality, clustering, and influence within the network.

The project demonstrates how language data can be transformed into a network graph for meaningful network analysis.

## 🛠️ Technologies & Libraries Used

### Python:
- **spaCy** – for named entity recognition (NER) and relationship extraction
- **Pandas, NumPy** – for data manipulation and cleaning

### R / RStudio:
- **igraph** – for advanced network analysis and community detection
- **tidyverse** – for data wrangling and transformation
- **ggraph** – for aesthetic graph plotting and layouts

## 🚀 Project Highlights

- Extracted named job titles, programming languages and libraries from text using `spaCy`.
- Created edge lists from co-occurrences and semantic relationships to form undirected network graphs.
- Analyzed networks using degree centrality, betweenness centrality, and community structures.
- Used R’s `igraph` and `ggraph` for robust network visualization and interpretation.

## 📁 Project Structure
```bash
COSC421_Project/
│ ├── Data PreProcessing/
 │ └── Data_Cleaning.ipynb │
├── Data/ │
 ├── Kaggle_Dataset_1.csv │
 ├── Kaggle_Dataset_2.csv │
 ├── Skillset.xlsx │
 ├── raw_data.csv
 │ └── Data.csv │
├── NLP/ │
 ├── input/ │
  │ ├── Skillset.xlsx │
  │ └── raw_data.csv │
 ├── output/ │
  │ └── Data.csv
 │ └── src/ │
  ├── constants.py │
  ├── func.py
  │ └── spaCy_parser.py │
├── R/ │
 ├── Graph.R
 │ └── Metrics.R │
├── Report/
 │ └── Images/ │... (figures for report)
 ├── TG_27012699_KS_80384878
│ └── README.md
```
---

## 🧠 Key Technologies

- **Python**: Data cleaning, NLP with spaCy, data parsing.
- **spaCy**: NLP model for tokenization, named entity recognition (NER), and pattern matching.
- **R (RStudio)**: Visualization and statistical metrics (bar plots, accuracy metrics).
- **pandas / NumPy**: For tabular data manipulation in Python.
- **xlsx / csv**: Structured input/output data formats.

---

## 🚀 Features

- Preprocessing of multiple resume datasets.
- NLP skill extraction from unstructured resume text using `spaCy`.
- Data cleaning, formatting, and exporting into unified formats.
- Visualization of skill distributions and extraction metrics in R.
- Modular Python scripts for reusability (`func.py`, `constants.py`).
- Organized output for further statistical analysis.

---


### Python Environment

1. Install dependencies:
```bash
pip install pandas numpy spacy openpyxl
python -m spacy download en_core_web_sm
```

2. Navigate to NLP/src and run:

```bash 
python spaCy_parser.py
 ```

3. R Environment
- Open R/Graph.R and R/Metrics.R in RStudio.
- Modify file paths if necessary to point to output/Data.csv.
- Run the scripts to generate graphs and accuracy reports.

📄 Output
- Parsed and cleaned CSV files containing skill entities.
- Graphical representations of frequency and match percentages.
- Statistical summaries of extraction performance.

✍️ Authors
- Taksh Girdhar – UBC Data Science BSc
- Kussh S. – UBC Computer Science BSc

License
-This project is for educational and academic purposes only.

