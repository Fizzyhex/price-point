local types = {}

for _, assetType in Enum.AssetType:GetEnumItems() do
	table.insert(types, `{assetType.Name} = {assetType.Value}`)
end

print(table.concat(types, "\n"))