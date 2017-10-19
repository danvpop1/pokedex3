//
//  Pokemon.swift
//  pokedex
//
//  Created by Razvan Bogdan on 5/24/17.
//  Copyright © 2017 Razvan Bogdan. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    fileprivate var _name: String!
    fileprivate var _pokedexId: Int!
    fileprivate var _description: String!
    fileprivate var _type: String!
    fileprivate var _defense: String!
    fileprivate var _height: String!
    fileprivate var _weight: String!
    fileprivate var _attack: String!
    fileprivate var _nextEvolutionTxt: String!
    fileprivate var _pokemonURL: String!
    fileprivate var _nextEvolutionName: String!
    fileprivate var _nextEvolutionId: String!
    fileprivate var _nextEvolutionLevel: String!

    var name: String {
        return _name
    }

    var pokedexId: Int {
        return _pokedexId
    }

    var nextEvolutionTxt: String {
        if self._nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        
        return _nextEvolutionTxt
    }

    var attack: String {
        if self._attack == nil {
            _attack = ""
        }
        
        return _attack
    }

    var weight: String {
        if self._weight == nil {
            self._weight = ""
        }
        
        return self._weight
    }

    var height: String {
        if self._height == nil {
            self._height = ""
        }
        
        return self._height
    }

    var defense: String {
        if self._defense == nil {
            self._defense = ""
        }
        
        return self._defense
    }

    var type: String {
        if self._type == nil {
            self._type = ""
        }
        
        return self._type
    }

    var desc: String {
        if self._description == nil {
            self._description = ""
        }
        
        return self._description
    }

    var nextEvolutionName: String {
        if self._nextEvolutionName == nil {
            self._nextEvolutionName = ""
        }

        return self._nextEvolutionName
    }

    var nextEvolutionId: String {
        if self._nextEvolutionId == nil {
            self._nextEvolutionId = ""
        }

        return self._nextEvolutionId
    }

    var nextEvolutionLevel: String {
        if self._nextEvolutionLevel == nil {
            self._nextEvolutionLevel = ""
        }

        return self._nextEvolutionLevel
    }


    init(name: String, pokedexId: Int) {
        self._name = name
        self._pokedexId = pokedexId

        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexId!)/"
    }
    func downloadPokemonDetail(complete: @escaping DownloadComplete) {
        Alamofire.request(self._pokemonURL!).responseJSON { response in

            if let dict = response.result.value as? Dictionary<String, AnyObject> {
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }

                if let height = dict["height"] as? String {
                    self._height = height
                }

                if let attack = dict["attack"] as? Int {
                    self._attack = "\(attack)"
                }

                if let defense = dict["defense"] as? Int {
                    self._defense = "\(defense)"
                }

                if let types = dict["types"] as? [Dictionary<String, String>], types.count > 0 {
                    if let name = types[0]["name"] {
                        self._type = name.capitalized
                    }

                    if types.count > 1 {
                        for type in 1..<types.count {
                            if let name = types[type]["name"] {
                                self._type! += "/\(name.capitalized)"
                            }

                        }
                    }
                } else {
                    self._type = ""
                }

                if let descriptionArray = dict["descriptions"] as? [Dictionary<String, String>], descriptionArray.count > 0 {
                    if let descriptionURL = descriptionArray[0]["resource_uri"] {
                        Alamofire.request(URL_BASE + descriptionURL).responseJSON { (response) in

                            if let descriptionDict = response.result.value as? Dictionary<String, AnyObject> {
                                if let description = descriptionDict["description"] as? String {
                                    print(description)
                                    self._description = description
                                }
                            }
                            complete()
                        }
                    }

                } else {
                    self._description = ""
                }

                if let evolutionArray = dict["evolutions"] as? [Dictionary<String, AnyObject>], evolutionArray.count > 0 {
                    if let nextEvolution = evolutionArray[0]["to"] as? String {
                        if nextEvolution.range(of: "mega") == nil {
                            self._nextEvolutionName = nextEvolution
                            if let uri = evolutionArray[0]["resource_uri"] {
                                let newStr = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                                let nextEvoId = newStr.replacingOccurrences(of: "/", with: "")
                                self._nextEvolutionId = nextEvoId

                                if let levelExist = evolutionArray[0]["level"] {
                                    if let level = levelExist as? Int {
                                        self._nextEvolutionLevel = "\(level)"
                                    }
                                } else {
                                    self._nextEvolutionLevel = ""
                                }
                            }
                        }
                    }

                    print("next lvl: " + self.nextEvolutionLevel)
                    print("next name: " + self.nextEvolutionName)
                    print("next id: " + self.nextEvolutionId)
                }
            }

            complete()
        }
    }
}
