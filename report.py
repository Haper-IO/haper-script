from typing import Optional, List, Any, Dict, TypeVar, Callable, Type, cast
from datetime import datetime
from enum import Enum
import dateutil.parser


T = TypeVar("T")
EnumT = TypeVar("EnumT", bound=Enum)


def from_str(x: Any) -> str:
    assert isinstance(x, str)
    return x


def from_none(x: Any) -> Any:
    assert x is None
    return x


def from_union(fs, x):
    for f in fs:
        try:
            return f(x)
        except:
            pass
    assert False


def from_int(x: Any) -> int:
    assert isinstance(x, int) and not isinstance(x, bool)
    return x


def from_datetime(x: Any) -> datetime:
    return dateutil.parser.parse(x)


def from_list(f: Callable[[Any], T], x: Any) -> List[T]:
    assert isinstance(x, list)
    return [f(y) for y in x]


def to_class(c: Type[T], x: Any) -> dict:
    assert isinstance(x, c)
    return cast(Any, x).to_dict()


def from_bool(x: Any) -> bool:
    assert isinstance(x, bool)
    return x


def to_enum(c: Type[EnumT], x: Any) -> EnumT:
    assert isinstance(x, c)
    return x.value


def from_dict(f: Callable[[Any], T], x: Any) -> Dict[str, T]:
    assert isinstance(x, dict)
    return { k: f(v) for (k, v) in x.items() }


class MailMessageItem:
    action: str
    action_result: Optional[str]
    category: str
    id: int
    message_id: str
    receive_at: datetime
    reply_message: Optional[str]
    sender: str
    subject: str
    summary: str
    tags: List[str]
    thread_id: str

    def __init__(self, action: str, action_result: Optional[str], category: str, id: int, message_id: str, receive_at: datetime, reply_message: Optional[str], sender: str, subject: str, summary: str, tags: List[str], thread_id: str) -> None:
        self.action = action
        self.action_result = action_result
        self.category = category
        self.id = id
        self.message_id = message_id
        self.receive_at = receive_at
        self.reply_message = reply_message
        self.sender = sender
        self.subject = subject
        self.summary = summary
        self.tags = tags
        self.thread_id = thread_id

    @staticmethod
    def from_dict(obj: Any) -> 'MailMessageItem':
        assert isinstance(obj, dict)
        action = from_str(obj.get("action"))
        action_result = from_union([from_none, from_str], obj.get("action_result"))
        category = from_str(obj.get("category"))
        id = from_int(obj.get("id"))
        message_id = from_str(obj.get("message_id"))
        receive_at = from_datetime(obj.get("receive_at"))
        reply_message = from_union([from_str, from_none], obj.get("reply_message"))
        sender = from_str(obj.get("sender"))
        subject = from_str(obj.get("subject"))
        summary = from_str(obj.get("summary"))
        tags = from_list(from_str, obj.get("tags"))
        thread_id = from_str(obj.get("thread_id"))
        return MailMessageItem(action, action_result, category, id, message_id, receive_at, reply_message, sender, subject, summary, tags, thread_id)

    def to_dict(self) -> dict:
        result: dict = {}
        result["action"] = from_str(self.action)
        result["action_result"] = from_union([from_none, from_str], self.action_result)
        result["category"] = from_str(self.category)
        result["id"] = from_int(self.id)
        result["message_id"] = from_str(self.message_id)
        result["receive_at"] = self.receive_at.isoformat()
        if self.reply_message is not None:
            result["reply_message"] = from_union([from_str, from_none], self.reply_message)
        result["sender"] = from_str(self.sender)
        result["subject"] = from_str(self.subject)
        result["summary"] = from_str(self.summary)
        result["tags"] = from_list(from_str, self.tags)
        result["thread_id"] = from_str(self.thread_id)
        return result


class MailMessagesByAccount:
    account_id: str
    email: str
    messages: List[MailMessageItem]

    def __init__(self, account_id: str, email: str, messages: List[MailMessageItem]) -> None:
        self.account_id = account_id
        self.email = email
        self.messages = messages

    @staticmethod
    def from_dict(obj: Any) -> 'MailMessagesByAccount':
        assert isinstance(obj, dict)
        account_id = from_str(obj.get("account_id"))
        email = from_str(obj.get("email"))
        messages = from_list(MailMessageItem.from_dict, obj.get("messages"))
        return MailMessagesByAccount(account_id, email, messages)

    def to_dict(self) -> dict:
        result: dict = {}
        result["account_id"] = from_str(self.account_id)
        result["email"] = from_str(self.email)
        result["messages"] = from_list(lambda x: to_class(MailMessageItem, x), self.messages)
        return result


class ReportContent:
    content_sources: List[str]
    gmail: Optional[List[MailMessagesByAccount]]
    outlook: Optional[List[MailMessagesByAccount]]

    def __init__(self, content_sources: List[str], gmail: Optional[List[MailMessagesByAccount]], outlook: Optional[List[MailMessagesByAccount]]) -> None:
        self.content_sources = content_sources
        self.gmail = gmail
        self.outlook = outlook

    @staticmethod
    def from_dict(obj: Any) -> 'ReportContent':
        assert isinstance(obj, dict)
        content_sources = from_list(from_str, obj.get("content_sources"))
        gmail = from_union([lambda x: from_list(MailMessagesByAccount.from_dict, x), from_none], obj.get("gmail"))
        outlook = from_union([lambda x: from_list(MailMessagesByAccount.from_dict, x), from_none], obj.get("outlook"))
        return ReportContent(content_sources, gmail, outlook)

    def to_dict(self) -> dict:
        result: dict = {}
        result["content_sources"] = from_list(from_str, self.content_sources)
        if self.gmail is not None:
            result["gmail"] = from_union([lambda x: from_list(lambda x: to_class(MailMessagesByAccount, x), x), from_none], self.gmail)
        if self.outlook is not None:
            result["outlook"] = from_union([lambda x: from_list(lambda x: to_class(MailMessagesByAccount, x), x), from_none], self.outlook)
        return result


class Annotations:
    bold: Optional[bool]

    def __init__(self, bold: Optional[bool]) -> None:
        self.bold = bold

    @staticmethod
    def from_dict(obj: Any) -> 'Annotations':
        assert isinstance(obj, dict)
        bold = from_union([from_bool, from_none], obj.get("bold"))
        return Annotations(bold)

    def to_dict(self) -> dict:
        result: dict = {}
        if self.bold is not None:
            result["bold"] = from_union([from_bool, from_none], self.bold)
        return result


class Email:
    address: str
    name: str

    def __init__(self, address: str, name: str) -> None:
        self.address = address
        self.name = name

    @staticmethod
    def from_dict(obj: Any) -> 'Email':
        assert isinstance(obj, dict)
        address = from_str(obj.get("address"))
        name = from_str(obj.get("name"))
        return Email(address, name)

    def to_dict(self) -> dict:
        result: dict = {}
        result["address"] = from_str(self.address)
        result["name"] = from_str(self.name)
        return result


class Text:
    content: str

    def __init__(self, content: str) -> None:
        self.content = content

    @staticmethod
    def from_dict(obj: Any) -> 'Text':
        assert isinstance(obj, dict)
        content = from_str(obj.get("content"))
        return Text(content)

    def to_dict(self) -> dict:
        result: dict = {}
        result["content"] = from_str(self.content)
        return result


class TypeEnum(Enum):
    EMAIL = "email"
    TEXT = "text"


class RichText:
    annotations: Optional[Annotations]
    email: Optional[Email]
    text: Optional[Text]
    type: TypeEnum

    def __init__(self, annotations: Optional[Annotations], email: Optional[Email], text: Optional[Text], type: TypeEnum) -> None:
        self.annotations = annotations
        self.email = email
        self.text = text
        self.type = type

    @staticmethod
    def from_dict(obj: Any) -> 'RichText':
        assert isinstance(obj, dict)
        annotations = from_union([Annotations.from_dict, from_none], obj.get("annotations"))
        email = from_union([Email.from_dict, from_none], obj.get("email"))
        text = from_union([Text.from_dict, from_none], obj.get("text"))
        type = TypeEnum(obj.get("type"))
        return RichText(annotations, email, text, type)

    def to_dict(self) -> dict:
        result: dict = {}
        if self.annotations is not None:
            result["annotations"] = from_union([lambda x: to_class(Annotations, x), from_none], self.annotations)
        if self.email is not None:
            result["email"] = from_union([lambda x: to_class(Email, x), from_none], self.email)
        if self.text is not None:
            result["text"] = from_union([lambda x: to_class(Text, x), from_none], self.text)
        result["type"] = to_enum(TypeEnum, self.type)
        return result


class Report:
    content: ReportContent
    messages_in_queue: Dict[str, int]
    summary: List[RichText]

    def __init__(self, content: ReportContent, messages_in_queue: Dict[str, int], summary: List[RichText]) -> None:
        self.content = content
        self.messages_in_queue = messages_in_queue
        self.summary = summary

    @staticmethod
    def from_dict(obj: Any) -> 'Report':
        assert isinstance(obj, dict)
        content = ReportContent.from_dict(obj.get("content"))
        messages_in_queue = from_dict(from_int, obj.get("messages_in_queue"))
        summary = from_list(RichText.from_dict, obj.get("summary"))
        return Report(content, messages_in_queue, summary)

    def to_dict(self) -> dict:
        result: dict = {}
        result["content"] = to_class(ReportContent, self.content)
        result["messages_in_queue"] = from_dict(from_int, self.messages_in_queue)
        result["summary"] = from_list(lambda x: to_class(RichText, x), self.summary)
        return result


def report_from_dict(s: Any) -> Report:
    return Report.from_dict(s)


def report_to_dict(x: Report) -> Any:
    return to_class(Report, x)
