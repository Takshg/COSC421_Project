# Import libraries
from collections import Counter
import pandas as pd

def create_profile(nlp, matcher, text):
    # Process the text with spaCy
    doc = nlp(text)
    
    # Find matches
    matches = matcher(doc)
    
    # Collect matched CS Fields and programming languages
    matched_data = []
    for match_id, start, end in matches:
        skill = nlp.vocab.strings[match_id] 
        sub_skill = doc[start:end].text  
        matched_data.append((skill, sub_skill))
    
    # Count occurrences of each programming language-CS field pair
    data = []
    for (skill, sub_skill), count in Counter(matched_data).items():
        data.append([skill, sub_skill, count])
    
    # Convert data to a DataFrame
    return pd.DataFrame(data, columns=['CS Field', 'Language', 'Count'])

def df(final_database):
    # Aggregate programming languages counts by company name and CS Field
    aggregated_data = final_database['Language'].groupby(
        [final_database['Company/Candidate Name'], final_database['Skill']]
    ).count().unstack() 

    # Reset index and fill missing values with 0
    aggregated_data.reset_index(inplace=True)
    aggregated_data.fillna(0, inplace=True)

    # Prepare data
    skillset_data = aggregated_data.iloc[:, 1:]
    skillset_data.index = aggregated_data['Company/Candidate Name']


