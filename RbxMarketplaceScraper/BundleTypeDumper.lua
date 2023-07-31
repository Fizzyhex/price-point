local types = {}

for _, bundleType in Enum.BundleType:GetEnumItems() do
	table.insert(types, `{bundleType.Name} = {bundleType.Value}`)
end

print(table.concat(types, "\n"))