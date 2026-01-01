import Vapor

protocol DTORepresentable {
  associatedtype DTO
  func toDto() -> DTO
}
