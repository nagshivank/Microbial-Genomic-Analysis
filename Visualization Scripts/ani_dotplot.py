import pandas as pd
import matplotlib.pyplot as plt
import warnings

# Suppress FutureWarning
warnings.simplefilter(action='ignore', category=FutureWarning)

# Load data
ani_file = "fastANI_compiled_results.tsv"
headers = ["query", "reference", "ANI", "query_fragments", "reference_fragments"]
ani_df = pd.read_csv(ani_file, delimiter="\t", names=headers)

# Calculate coverage
ani_df["Coverage"] = (ani_df["query_fragments"] / ani_df["reference_fragments"]) * 100

# Strip characters off of the query column
ani_df['query'] = ani_df['query'].str.replace('fna/processed_', '')
ani_df['query'] = ani_df['query'].str.replace('_shovill_spades.fna', '')

print(f'ANI range: {min(ani_df["ANI"]):.2f} - {max(ani_df["ANI"]):.2f}')
print(f'Coverage range: {min(ani_df["Coverage"]):.2f} - {max(ani_df["Coverage"]):.2f}')

# Plot ANI/Coverage
plt.figure(figsize=(16, 7))
plt.scatter(ani_df["ANI"], ani_df["Coverage"], color="blue")

# Annotate each point with its corresponding query
for i, txt in enumerate(ani_df["query"]):
    plt.text(ani_df["ANI"][i], ani_df["Coverage"][i], txt, fontsize=8, ha='right', va='bottom')


# Draw plots
plt.ylabel("% Query Coverage")
plt.xlabel("% ANI")
plt.title('FastANI: "Unknowns" all vs. GCF_018885085.1 (Clostridioides difficile)')
plt.xlim(99, 100)
plt.ylim(80, 100)
plt.grid(True)

# Save the figure to a PNG file
plt.savefig('fastANI_compiled_results.dotplot.png')

plt.show()