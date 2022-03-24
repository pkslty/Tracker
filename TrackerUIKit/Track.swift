//
//  Track.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 23.03.2022.
//

import Foundation
import RealmSwift

class Track: Object {
    @Persisted var startDate: Date = Date()
    @Persisted var endDate: Date?
    @Persisted var encodedPaths: List<String?>
    @Persisted var completePath: String?
}
