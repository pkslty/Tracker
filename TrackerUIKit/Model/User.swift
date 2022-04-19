//
//  User.swift
//  CoordinatorPattern
//
//  Created by Denis Kuzmin on 28.03.2022.
//

import Foundation
import RealmSwift

class User: Object {
    @Persisted(primaryKey: true) var login: String
    @Persisted var passwordHash: String
    @Persisted var name: String
    @Persisted var id: UUID
    @Persisted var useAvatarForTracking: Bool
}
