new=0
old=0
file_name="$1"
read -p "enter new: " new_text
read -p "enter old: " old_text

sed -i "s/$old_text/$new_text/g" "$file_name"

echo "Replacement done in $file_name"

