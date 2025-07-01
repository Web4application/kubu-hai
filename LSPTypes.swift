import Foundation
import JSONRPC
import LanguageServerProtocol

// MARK: Conversation template
public struct ChatTemplate: Codable, Equatable {
    public var id: String
    public var description: String
    public var shortDescription: String
    public var scopes: [PromptTemplateScope]
    
    public init(id: String, description: String, shortDescription: String, scopes: [PromptTemplateScope]=[]) {
        self.id = id
        self.description = description
        self.shortDescription = shortDescription
        self.scopes = scopes
    }
}

public enum PromptTemplateScope: String, Codable, Equatable {
    case chatPanel = "chat-panel"
    case editPanel = "edit-panel"
    case agentPanel = "agent-panel"
    case editor = "editor"
    case inline = "inline"
    case completion = "completion"
}

public struct CopilotLanguageServerError: Codable {
    public var code: Int?
    public var message: String
    public var responseIsIncomplete: Bool?
    public var responseIsFiltered: Bool?
}

// MARK: Copilot Model
public struct CopilotModel: Codable, Equatable {
    public let modelFamily: String
    public let modelName: String
    public let id: String
    public let modelPolicy: CopilotModelPolicy?
    public let scopes: [PromptTemplateScope]
    public let preview: Bool
    public let isChatDefault: Bool
    public let isChatFallback: Bool
    public let capabilities: CopilotModelCapabilities
    public let billing: CopilotModelBilling?
}

public struct CopilotModelPolicy: Codable, Equatable {
    public let state: String
    public let terms: String
}

public struct CopilotModelCapabilities: Codable, Equatable {
    public let supports: CopilotModelCapabilitiesSupports
}

public struct CopilotModelCapabilitiesSupports: Codable, Equatable {
    public let vision: Bool
}

public struct CopilotModelBilling: Codable, Equatable, Hashable {
    public let isPremium: Bool
    public let multiplier: Float
}

// MARK: Conversation Agents
public struct ChatAgent: Codable, Equatable {
    public let slug: String
    public let name: String
    public let description: String
    public let avatarUrl: String?
    
    public init(slug: String, name: String, description: String, avatarUrl: String?) {
        self.slug = slug
        self.name = name
        self.description = description
        self.avatarUrl = avatarUrl
    }
}

// MARK: EditAgent

public struct RegisterToolsParams: Codable, Equatable {
    public let tools: [LanguageModelToolInformation]

    public init(tools: [LanguageModelToolInformation]) {
        self.tools = tools
    }
}

public struct LanguageModelToolInformation: Codable, Equatable {
    /// The name of the tool.
    public let name: String

    /// A description of this tool that may be used by a language model to select it.
    public let description: String

    /// A JSON schema for the input this tool accepts. The input must be an object at the top level.
    /// A particular language model may not support all JSON schema features.
    public let inputSchema: LanguageModelToolSchema?

    public let confirmationMessages: LanguageModelToolConfirmationMessages?

    public init(name: String, description: String, inputSchema: LanguageModelToolSchema?, confirmationMessages: LanguageModelToolConfirmationMessages? = nil) {
        self.name = name
        self.description = description
        self.inputSchema = inputSchema
        self.confirmationMessages = confirmationMessages
    }
}

public struct LanguageModelToolSchema: Codable, Equatable {
    public let type: String
    public let properties: [String: ToolInputPropertySchema]
    public let required: [String]
    
    public init(type: String, properties: [String : ToolInputPropertySchema], required: [String]) {
        self.type = type
        self.properties = properties
        self.required = required
    }
}

public struct ToolInputPropertySchema: Codable, Equatable {
    public struct Items: Codable, Equatable {
        public let type: String
        
        public init(type: String) {
            self.type = type
        }
    }
    
    public let type: String
    public let description: String
    public let items: Items?
    
    public init(type: String, description: String, items: Items? = nil) {
        self.type = type
        self.description = description
        self.items = items
    }
}

public struct LanguageModelToolConfirmationMessages: Codable, Equatable {
    public let title: String
    public let message: String
    
    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}

public struct InvokeClientToolParams: Codable, Equatable {
    /// The name of the tool to be invoked.
    public let name: String

    /// The input to the tool.
    public let input: [String: AnyCodable]?

    /// The ID of the conversation this tool invocation belongs to.
    public let conversationId: String

    /// The ID of the turn this tool invocation belongs to.
    public let turnId: String

    /// The ID of the round this tool invocation belongs to.
    public let roundId: Int

    /// The unique ID for this specific tool call.
    public let toolCallId: String

    /// The title of the tool confirmation.
    public let title: String?

    /// The message of the tool confirmation.
    public let message: String?
}

/// A helper type to encode/decode `Any` values in JSON.
public struct AnyCodable: Codable, Equatable {
    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as [AnyCodable], rhs as [AnyCodable]):
            return lhs == rhs
        case let (lhs as [String: AnyCodable], rhs as [String: AnyCodable]):
            return lhs == rhs
        default:
            return false
        }
    }
    
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
            value = dictionaryValue.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else if let arrayValue = value as? [Any] {
            try container.encode(arrayValue.map { AnyCodable($0) })
        } else if let dictionaryValue = value as? [String: Any] {
            try container.encode(dictionaryValue.mapValues { AnyCodable($0) })
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported type"))
        }
    }
}

public typealias InvokeClientToolRequest = JSONRPCRequest<InvokeClientToolParams>

public struct LanguageModelToolResult: Codable, Equatable {
    public struct Content: Codable, Equatable {
        public let value: AnyCodable
        
        public init(value: Any) {
            self.value = AnyCodable(value)
        }
    }
    
    public let content: [Content]
    
    public init(content: [Content]) {
        self.content = content
    }
}

public struct Doc: Codable {
    var uri: String
    
    public init(uri: String) {
        self.uri = uri
    }
}

public enum ToolConfirmationResult: String, Codable {
    /// The user accepted the tool invocation.
    case Accept = "accept"
    /// The user dismissed the tool invocation.
    case Dismiss = "dismiss"
}

public struct LanguageModelToolConfirmationResult: Codable, Equatable {
    /// The result of the confirmation.
    public let result: ToolConfirmationResult
    
    public init(result: ToolConfirmationResult) {
        self.result = result
    }
}

public typealias InvokeClientToolConfirmationRequest = JSONRPCRequest<InvokeClientToolParams>

// MARK: CLS ShowMessage Notification
public struct CopilotShowMessageParams: Codable, Equatable, Hashable {
    public var type: MessageType
    public var title: String
    public var message: String
    public var actions: [CopilotMessageActionItem]?
    public var location: CopilotMessageLocation
    public var panelContext: CopilotMessagePanelContext?
    
    public init(
        type: MessageType,
        title: String,
        message: String,
        actions: [CopilotMessageActionItem]? = nil,
        location: CopilotMessageLocation,
        panelContext: CopilotMessagePanelContext? = nil
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.actions = actions
        self.location = location
        self.panelContext = panelContext
    }
}

public enum CopilotMessageLocation: String, Codable, Equatable, Hashable {
    case Panel = "Panel"
    case Inline = "Inline"
}

public struct CopilotMessagePanelContext: Codable, Equatable, Hashable {
    public var conversationId: String
    public var turnId: String
}

public struct CopilotMessageActionItem: Codable, Equatable, Hashable {
    public var title: String
    public var command: ActionCommand?
}

public struct ActionCommand: Codable, Equatable, Hashable {
    public var commandId: String
    public var args: LSPAny?
}
