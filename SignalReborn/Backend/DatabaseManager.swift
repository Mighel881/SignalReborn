//
//  DatabaseManager.swift
//  SignalReborn
//
//  Created by Amy While on 25/09/2020.
//  Copyright © 2020 Amy While. All rights reserved.
//

import Foundation
import MapKit
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    var database: Connection!
    var cells = [Cell]()
    
    //MARK: - Stealing the database from locationd
    @discardableResult func copyTheDatabase() -> Bool {
        #if Jailed
        #else
        do {
            let database = try Connection("/var/root/Library/Caches/locationd/cache_encryptedB.db")
            self.database = database
            return true
        } catch {
            print(error)
        }
        #endif
        return false
    }
    
    //MARK: - What converts the table into codable cells
    func prepareCells() {
        do {
            let lteCellTable = Table("LteCellLocation")
            let gsmCellTable = Table("CellLocation")
            let cdmaCellTable = Table("CdmaCellLocation")
            
            let Latitude = Expression<Double>("Latitude")
            let Longitude = Expression<Double>("Longitude")
            let MNC = Expression<Int>("MNC")
            let MCC = Expression<Int>("MCC")
            let cellID = Expression<Int>("CI")
            let SID = Expression<Int>("SID")
            let TAC = Expression<Int>("TAC")
            let confidence = Expression<Int>("Confidence")
            
            let lteCells = try self.database.prepare(lteCellTable)
            let gsmCells = try self.database.prepare(gsmCellTable)
            let cdmaCells = try self.database.prepare(cdmaCellTable)
            
            for cell in lteCells {
                let lat = CLLocationDegrees(cell[Latitude])
                let lon = CLLocationDegrees(cell[Longitude])
                let id = cell[cellID]
                let confidence = cell[confidence]
                
                if id != -1 {
                    let mnc = cell[MNC]
                    let mcc = cell[MCC]
                    var isFound = false
                    
                    for carrier in CSVController.shared.carriers {
                        if carrier.mcc == mcc && carrier.mnc == mnc {
                            let cell = Cell(type: "LTE", mnc: mnc, mcc: mcc, cellID: id, lat: lat, lon: lon, confidence: confidence, tac: cell[TAC], carrier: carrier.carrier, cc: carrier.cc, iso: carrier.iso)
                            self.cells.append(cell)
                            isFound = true
                        }
                    }
                    
                    if !isFound {
                        let cell = Cell(type: "LTE", mnc: mnc, mcc: mcc, cellID: id, lat: lat, lon: lon, confidence: confidence, tac: cell[TAC])
                        self.cells.append(cell)
                    }
                }
            }
            
            for cell in gsmCells {
                let lat = CLLocationDegrees(cell[Latitude])
                let lon = CLLocationDegrees(cell[Longitude])
                let id = cell[cellID]
                let confidence = cell[confidence]
                
                if id != -1 {
                    let mcc = cell[MCC]
                    let mnc = cell[MNC]
                    var isFound = false
                    
                    for carrier in CSVController.shared.carriers {
                        if carrier.mcc == mcc && carrier.mnc == mnc {
                            let cell = Cell(type: "GSM", mnc: mnc, mcc: mcc, cellID: id, lat: lat, lon: lon, confidence: confidence, carrier: carrier.carrier, cc: carrier.cc, iso: carrier.iso)
                            self.cells.append(cell)
                            isFound = true
                        }
                    }
                    
                    if !isFound {
                        let cell = Cell(type: "GSM", mnc: mnc, mcc: mcc, cellID: id, lat: lat, lon: lon, confidence: confidence)
                        self.cells.append(cell)
                    }
                }
            }
            
            
            for cell in cdmaCells {
                let lat = CLLocationDegrees(cell[Latitude])
                let lon = CLLocationDegrees(cell[Longitude])
                let mcc = cell[MCC]
                let mnc = cell[SID]
                let confidence = cell[confidence]
                var isFound = false
                
                for carrier in CSVController.shared.carriers {
                    if carrier.mcc == mcc && carrier.mnc == mnc {
                        let cell = Cell(type: "CDMA", mnc: mnc, mcc: mcc, cellID: 0, lat: lat, lon: lon, confidence: confidence, carrier: carrier.carrier, cc: carrier.cc, iso: carrier.iso)
                        self.cells.append(cell)
                        isFound = true
                    }
                }
                
                if !isFound {
                    let cell = Cell(type: "CDMA", mnc: mnc, mcc: mcc, cellID: 0, lat: lat, lon: lon, confidence: confidence)
                    self.cells.append(cell)
                }
            }
 
        
        } catch {
            return
        }
    }
}

// MARK: - A cell type container
struct Cell {
    var type: String!
    var mnc: Int!
    var mcc: Int!
    var cellID: Int!
    var lat: CLLocationDegrees!
    var lon: CLLocationDegrees!
    var confidence: Int!
    var tac: Int!
    
    var carrier: String!
    var cc: Int!
    var iso: String!
}
