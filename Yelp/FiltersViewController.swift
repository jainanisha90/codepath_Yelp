//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Anisha Jain on 4/7/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc func filtersViewController(filtersViewController: FiltersViewController, didChangeFilter filters: SelectedFilters)
}

@objc class SelectedFilters:NSObject {
    var deals: Bool?
    var distance: String?
    var sortBy: String?
    var categories: [String] = []
}

class RadioController {
    var radioButtons: Set<UIButton> = []
    func selectRadio(_ button:UIButton) {
        radioButtons.forEach({ b in
            if (b != button) {
                b.isSelected = false
            }
        })
    }
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
        SwitchCellDelegate, RadioCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var filterStatus = [Int: [Int:Bool]?]()
    var filters: [FilterSection] = []
    let distanceRadioController:RadioController = RadioController()
    let sortByRadioController:RadioController = RadioController()
    
    weak var delegate: FiltersViewControllerDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedFilters = appDelegate.filter {
            filterStatus = savedFilters
        }
        filters = filterData()
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: "FilterSectionTitle", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "FilterSectionTitle")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters[section].filterCells?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionIndex = indexPath.section
        let filterValues = filters[sectionIndex].filterCells
        let filterCell = filterValues![indexPath.row]
        
        var isCellSelected = false
        if let selectedSection = filterStatus[sectionIndex] {
            isCellSelected = selectedSection?[indexPath.row] ?? false
        }
        
        switch sectionIndex {
        case 0, 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.filter = (filterCell.displayName, isCellSelected)
            cell.delegate = self
            return cell
        default:
            // Distance Filter, Sort By Filter
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell", for: indexPath) as! RadioCell
            cell.filter = (filterCell.displayName, isCellSelected)
            cell.delegate = self
            if(sectionIndex == 1) {
                distanceRadioController.radioButtons.insert(cell.onButton)
            } else {
                sortByRadioController.radioButtons.insert(cell.onButton)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterSectionTitle") as! FilterSectionTitle
        header.sectionTitle.text = filters[section].filterSectionTitle
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 0 : 34
        
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        let sectionIndex = indexPath.section
        
        if (filterStatus[sectionIndex] == nil) {
            filterStatus[sectionIndex] = [:]
        }

        var selectedCellsInSection = filterStatus[sectionIndex]!
        selectedCellsInSection?[indexPath.row] = value
        filterStatus[sectionIndex] = selectedCellsInSection
    }
    
    func radioCell(radioCell: RadioCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: radioCell)!
        let sectionIndex = indexPath.section
        
        if(sectionIndex == 1) {
            distanceRadioController.selectRadio(radioCell.onButton)
        } else {
            sortByRadioController.selectRadio(radioCell.onButton)
        }
        
        let selectedCellsInSection = [indexPath.row:value]
        filterStatus[sectionIndex] = selectedCellsInSection
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchButton(_ sender: Any) {
        let selectedFilters = SelectedFilters()
        for (sectionIndex, sectionData) in filterStatus {
            let filterSection = filters[sectionIndex]
            for (cellIndex, cellValue) in sectionData! {
                switch sectionIndex {
                case 0:
                    selectedFilters.deals = sectionData?[cellIndex]
                case 1:
                    if cellValue {
                        selectedFilters.distance = filterSection.filterCells[cellIndex].code
                    }
                case 2:
                    if cellValue {
                        selectedFilters.sortBy = filterSection.filterCells[cellIndex].code
                    }
                case 3:
                    if cellValue {
                        selectedFilters.categories.append(filterSection.filterCells[cellIndex].code!)
                    }
                default:
                    // do nothing
                    print("onSearchButton default case")
                }
            }
        }
        delegate?.filtersViewController(filtersViewController: self, didChangeFilter: selectedFilters)
        appDelegate.filter = filterStatus
        dismiss(animated: true, completion: nil)
    }
    
    func filterData() -> [FilterSection] {
        return [FilterSection("", [FilterCell("Offering a deal", "")]),
                FilterSection("Distance", yelpSearchDistance()),
                FilterSection("Sort By", yelpSortByModes()),
                FilterSection("Category", yelpCategories())]
    }
    
    func yelpSearchDistance() -> [FilterCell] {
        
        return [FilterCell("Auto", "40000"),    // Auto is 25 miles i.e. 40000 meters
                FilterCell("0.3 mile", "483"),
                FilterCell("1 mile", "1610"),
                FilterCell("5 miles", "8045"),
                FilterCell("20 miles", "32187")]
    }
    
    func yelpSortByModes() -> [FilterCell] {
        return [FilterCell("Best Match", String(describing: YelpSortMode.bestMatched.rawValue)),
                FilterCell("Distance", String(describing: YelpSortMode.distance.rawValue)),
                FilterCell("Higest Rated", String(describing: YelpSortMode.highestRated.rawValue))]
    }
    
    func yelpCategories() -> [FilterCell] {
        return   [FilterCell("Afghan", "afghani"),
                  FilterCell("African", "african"),
                  FilterCell("American, New", "newamerican"),
                  FilterCell("American, Traditional", "tradamerican"),
                  FilterCell("Arabian", "arabian"),
                  FilterCell("Argentine", "argentine"),
                  FilterCell("Armenian", "armenian"),
                  FilterCell("Asian Fusion", "asianfusion"),
                  FilterCell("Asturian", "asturian"),
                  FilterCell("Australian", "australian"),
                  FilterCell("Austrian", "austrian"),
                  FilterCell("Baguettes", "baguettes"),
                  FilterCell("Bangladeshi", "bangladeshi"),
                  FilterCell("Barbeque", "bbq"),
                  FilterCell("Basque", "basque"),
                  FilterCell("Bavarian", "bavarian"),
                  FilterCell("Beer Garden", "beergarden"),
                  FilterCell("Beer Hall", "beerhall"),
                  FilterCell("Beisl", "beisl"),
                  FilterCell("Belgian", "belgian"),
                  FilterCell("Bistros", "bistros"),
                  FilterCell("Black Sea", "blacksea"),
                  FilterCell("Brasseries", "brasseries"),
                  FilterCell("Brazilian", "brazilian"),
                  FilterCell("Breakfast & Brunch", "breakfast_brunch"),
                  FilterCell("British", "british"),
                  FilterCell("Buffets", "buffets"),
                  FilterCell("Bulgarian", "bulgarian"),
                  FilterCell("Burgers", "burgers"),
                  FilterCell("Burmese", "burmese"),
                  FilterCell("Cafes", "cafes"),
                  FilterCell("Cafeteria", "cafeteria"),
                  FilterCell("Cajun/Creole", "cajun"),
                  FilterCell("Cambodian", "cambodian"),
                  FilterCell("Canadian", "New)"),
                  FilterCell("Canteen", "canteen"),
                  FilterCell("Caribbean", "caribbean"),
                  FilterCell("Catalan", "catalan"),
                  FilterCell("Chech", "chech"),
                  FilterCell("Cheesesteaks", "cheesesteaks"),
                  FilterCell("Chicken Shop", "chickenshop"),
                  FilterCell("Chicken Wings", "chicken_wings"),
                  FilterCell("Chilean", "chilean"),
                  FilterCell("Chinese", "chinese"),
                  FilterCell("Comfort Food", "comfortfood"),
                  FilterCell("Corsican", "corsican"),
                  FilterCell("Creperies", "creperies"),
                  FilterCell("Cuban", "cuban"),
                  FilterCell("Curry Sausage", "currysausage"),
                  FilterCell("Cypriot", "cypriot"),
                  FilterCell("Czech", "czech"),
                  FilterCell("Czech/Slovakian", "czechslovakian"),
                  FilterCell("Danish", "danish"),
                  FilterCell("Delis", "delis"),
                  FilterCell("Diners", "diners"),
                  FilterCell("Dumplings", "dumplings"),
                  FilterCell("Eastern European", "eastern_european"),
                  FilterCell("Ethiopian", "ethiopian"),
                  FilterCell("Fast Food", "hotdogs"),
                  FilterCell("Filipino", "filipino"),
                  FilterCell("Fish & Chips", "fishnchips"),
                  FilterCell("Fondue", "fondue"),
                  FilterCell("Food Court", "food_court"),
                  FilterCell("Food Stands", "foodstands"),
                  FilterCell("French", "french"),
                  FilterCell("French Southwest", "sud_ouest"),
                  FilterCell("Galician", "galician"),
                  FilterCell("Gastropubs", "gastropubs"),
                  FilterCell("Georgian", "georgian"),
                  FilterCell("German", "german"),
                  FilterCell("Giblets", "giblets"),
                  FilterCell("Gluten-Free", "gluten_free"),
                  FilterCell("Greek", "greek"),
                  FilterCell("Halal", "halal"),
                  FilterCell("Hawaiian", "hawaiian"),
                  FilterCell("Heuriger", "heuriger"),
                  FilterCell("Himalayan/Nepalese", "himalayan"),
                  FilterCell("Hong Kong Style Cafe", "hkcafe"),
                  FilterCell("Hot Dogs", "hotdog"),
                  FilterCell("Hot Pot", "hotpot"),
                  FilterCell("Hungarian", "hungarian"),
                  FilterCell("Iberian", "iberian"),
                  FilterCell("Indian", "indpak"),
                  FilterCell("Indonesian", "indonesian"),
                  FilterCell("International", "international"),
                  FilterCell("Irish", "irish"),
                  FilterCell("Island Pub", "island_pub"),
                  FilterCell("Israeli", "israeli"),
                  FilterCell("Italian", "italian"),
                  FilterCell("Japanese", "japanese"),
                  FilterCell("Jewish", "jewish"),
                  FilterCell("Kebab", "kebab"),
                  FilterCell("Korean", "korean"),
                  FilterCell("Kosher", "kosher"),
                  FilterCell("Kurdish", "kurdish"),
                  FilterCell("Laos", "laos"),
                  FilterCell("Laotian", "laotian"),
                  FilterCell("Latin American", "latin"),
                  FilterCell("Live/Raw Food", "raw_food"),
                  FilterCell("Lyonnais", "lyonnais"),
                  FilterCell("Malaysian", "malaysian"),
                  FilterCell("Meatballs", "meatballs"),
                  FilterCell("Mediterranean", "mediterranean"),
                  FilterCell("Mexican", "mexican"),
                  FilterCell("Middle Eastern", "mideastern"),
                  FilterCell("Milk Bars", "milkbars"),
                  FilterCell("Modern Australian", "modern_australian"),
                  FilterCell("Modern European", "modern_european"),
                  FilterCell("Mongolian", "mongolian"),
                  FilterCell("Moroccan", "moroccan"),
                  FilterCell("New Zealand", "newzealand"),
                  FilterCell("Night Food", "nightfood"),
                  FilterCell("Norcinerie", "norcinerie"),
                  FilterCell("Open Sandwiches", "opensandwiches"),
                  FilterCell("Oriental", "oriental"),
                  FilterCell("Pakistani", "pakistani"),
                  FilterCell("Parent Cafes", "eltern_cafes"),
                  FilterCell("Parma", "parma"),
                  FilterCell("Persian/Iranian", "persian"),
                  FilterCell("Peruvian", "peruvian"),
                  FilterCell("Pita", "pita"),
                  FilterCell("Pizza", "pizza"),
                  FilterCell("Polish", "polish"),
                  FilterCell("Portuguese", "portuguese"),
                  FilterCell("Potatoes", "potatoes"),
                  FilterCell("Poutineries", "poutineries"),
                  FilterCell("Pub Food", "pubfood"),
                  FilterCell("Rice", "riceshop"),
                  FilterCell("Romanian", "romanian"),
                  FilterCell("Rotisserie Chicken", "rotisserie_chicken"),
                  FilterCell("Rumanian", "rumanian"),
                  FilterCell("Russian", "russian"),
                  FilterCell("Salad", "salad"),
                  FilterCell("Sandwiches", "sandwiches"),
                  FilterCell("Scandinavian", "scandinavian"),
                  FilterCell("Scottish", "scottish"),
                  FilterCell("Seafood", "seafood"),
                  FilterCell("Serbo Croatian", "serbocroatian"),
                  FilterCell("Signature Cuisine", "signature_cuisine"),
                  FilterCell("Singaporean", "singaporean"),
                  FilterCell("Slovakian", "slovakian"),
                  FilterCell("Soul Food", "soulfood"),
                  FilterCell("Soup", "soup"),
                  FilterCell("Southern", "southern"),
                  FilterCell("Spanish", "spanish"),
                  FilterCell("Steakhouses", "steak"),
                  FilterCell("Sushi Bars", "sushi"),
                  FilterCell("Swabian", "swabian"),
                  FilterCell("Swedish", "swedish"),
                  FilterCell("Swiss Food", "swissfood"),
                  FilterCell("Tabernas", "tabernas"),
                  FilterCell("Taiwanese", "taiwanese"),
                  FilterCell("Tapas Bars", "tapas"),
                  FilterCell("Tapas/Small Plates", "tapasmallplates"),
                  FilterCell("Tex-Mex", "tex-mex"),
                  FilterCell("Thai", "thai"),
                  FilterCell("Traditional Norwegian", "norwegian"),
                  FilterCell("Traditional Swedish", "traditional_swedish"),
                  FilterCell("Trattorie", "trattorie"),
                  FilterCell("Turkish", "turkish"),
                  FilterCell("Ukrainian", "ukrainian"),
                  FilterCell("Uzbek", "uzbek"),
                  FilterCell("Vegan", "vegan"),
                  FilterCell("Vegetarian", "vegetarian"),
                  FilterCell("Venison", "venison"),
                  FilterCell("Vietnamese", "vietnamese"),
                  FilterCell("Wok", "wok"),
                  FilterCell("Wraps", "wraps"),
                  FilterCell("Yugoslav", "yugoslav")]
    }

}
