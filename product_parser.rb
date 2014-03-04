require 'json'
require 'highscore'
require 'csv'

j = JSON.parse File.read 'beans.json'

j.each do |c|
 q,d,w = (c['quantity'].match /([0-9]+) (bags|boxes) \(([0-9]+) kg\)/)[1..3]
 c["Variant Inventory Qty"] = q.to_i*w.to_i / 10
 c["Variant Grams"] = 10000
 c["Variant Price"] = (5*22.04).to_i  
 c["description"] ||= ""
 c["Type"] = "Bean"
 c["Variant SKU"] = (c["title"].match /(SH[0-9]{4})/)[1]
 c["Variant Inventory Policy"] = "deny"
 c["Variant Fulfillment Service"] = "manual"
 c["Body (HTML)"] = c["description"]
 c['Variant Taxable'] = true
 c['Variant Requires Shipping'] = true
 h =  (c['title'].split("-")[0].downcase).strip.gsub(/("|,)/,"")
 h = h.split.length >= c['title'].split.length ? h.split[0..-2].join(" ") +' '+ c['Variant SKU'].downcase : h+' '+ c['Variant SKU'].downcase
 c['Handle'] = h.gsub(/\s/,'-')
 t = c['title'].split("-")
 c['title'] = t.length > 1 ? t[1..-1].join("-") : t.join
end

tagged = j.map {|c| c.merge({"tags" => c['description'].gsub(/(\.|,)/,'').keywords.rank.map{|i| i.text.downcase}.join(",")}) }
keys = %w(Handle Title Body\ (HTML) Vendor Type Tags Published Option1 Name Option1 Value Option2 Name Option2 Value Option3 Name Option3 Value Variant\ SKU Variant\ Grams Variant\ Inventory\ Tracker Variant\ Inventory\ Qty Variant\ Inventory\ Policy Variant\ Fulfillment\ Service Variant\ Price Variant\ Compare\ At\ Price Variant\ Requires\ Shipping Variant\ Taxable Variant\ Barcode Image\ Src Image\ Alt\ Text)

header = CSV::Row.new(keys,[],false)

table = CSV::Table.new([header])
p tagged[0]['tags']
tagged.each do |cof|
  r = CSV::Row.new([],[],false)
  cof.each do |k,v|
    if (ind = keys.map(&:downcase).index k.downcase)
      r << {keys[ind] => v}
    end
  end
  table << r.fields(*keys)
end
# puts table
CSV.open('products.csv','w',write_headers:true,headers: keys) do |csv|
  table.each do |r|
    csv << r 
  end
end

