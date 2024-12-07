# Import libraries
import pandas as pd
import spacy
from func import *  
from constants import *  
from tqdm import tqdm  
from spacy.matcher import PhraseMatcher
from collections import Counter  

# Load the spaCy model
nlp = spacy.load('en_core_web_sm')

# Load the skillset file (Excel format)
try:
    keyword_ = pd.read_excel(SKILL_FILE_PATH)
    print("Skill file loaded successfully!")
except Exception as e:
    print(f"Error loading skill file: {e}")
    exit() 

def init_parser_func(nlp, SKILL_FILE_PATH, file_type='excel'):
    """
    Initialize the PhraseMatcher and read the skillset data.

    :param nlp: Loaded spaCy NLP model
    :param SKILL_FILE_PATH: Path to the skillset data file
    :param file_type: Format of the skillset file ('excel' by default)
    :return: Initialized PhraseMatcher object
    """
    matcher = PhraseMatcher(nlp.vocab)

    if file_type == 'excel':
        keyword_[:] = keyword_.astype(str)

        for column in keyword_.columns:
            matcher.add(column, None, *[nlp(text) for text in keyword_[column].dropna()])

    return matcher


def create_profile(nlp, matcher, text):
    # Process the text with spaCy
    doc = nlp(text)

    # Find matches
    matches = matcher(doc)

    # Extract CS Fields and programming languages from matches
    matched_data = []
    for match_id, start, end in matches:
        rule_id = nlp.vocab.strings[match_id]
        span = doc[start:end]
        matched_data.append((rule_id, span.text))

    # Count occurrences of each Programming Language-CS Field pair
    data = []
    for (skill, sub_skill), count in Counter(matched_data).items():
        data.append([skill, sub_skill, count])

    # Convert to a DataFrame
    return pd.DataFrame(data, columns=['Skill', 'Sub-skill', 'Count'])


if __name__ == '__main__':
    # Initialize the matcher
    matcher = init_parser_func(nlp, SKILL_FILE_PATH)

    # Create an empty DataFrame
    final_database = pd.DataFrame()

    # Read input job descriptions
    try:
        df = pd.read_csv(
            "/Users/takshgirdhar/Desktop/COSC421_Project/Job-Description-Parser-master/Resume_JD_parser/input/raw_data.csv"
            # "/Users/kusshsatija/Desktop/COSC421/COSC421Project/Job-Description-Parser-master/Resume_JD_parser/input/raw_data.csv"
        )
        print("Job description data loaded successfully!")
    except Exception as e:
        print(f"Error reading raw data CSV: {e}")
        exit()  

    # Process each job description
    print("Processing job descriptions...")
    for i in tqdm(range(len(df))):
        text = df.loc[i, 'Description']
        profile_data = create_profile(nlp, matcher, text)
        final_database = pd.concat([final_database, profile_data], ignore_index=True)

    # Save the aggregated dataset to a CSV file
    output_path = '../output/Datav2.csv'
    final_database.to_csv(output_path, index=False)
    print(f"Processing complete! Data saved to '{output_path}'.")
