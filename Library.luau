local NodeType = {
    Unknown = 0,
    Root = 1,
    Category = 2,
    Section = 3,
    Header = 4,
    Entry = 5,
    UiElement = 6,
}

local Node = {}
Node.__index = Node

function Node:New(Type, Parent, GuiObject)
    local NodeInstance = setmetatable({}, Node)

    NodeInstance.Type = Type or NodeType.Unknown
    NodeInstance.Parent = Parent or NodeInstance.Parent
    NodeInstance.Children = {}
    NodeInstance.GuiObject = GuiObject or nil

    if Parent then
        Parent:AddChild(NodeInstance)
    end

    return NodeInstance
end

function Node:AddChild(Child)
    Child.Parent = self
    table.insert(self.Children, Child)

    if Child.GuiObject and self.GuiObject then
        Child.GuiObject.Parent = self.GuiObject
    end
end

function Node:RecursiveUpdateGui()
    self:UpdateGui()

    for Index, Child in ipairs(self.Children) do
        Child:RecursiveUpdateGui()
    end
end

function Node:UpdateGui()
end

local UiElement = {}
UiElement.__index = UiElement
setmetatable(UiElement, Node)

function UiElement:New(Size, Position, Title)
    local Element = setmetatable(Node:New(NodeType.UiElement), UiElement)

    Element.Value = nil
    Element.Title = Title
    Element.Size = Size
    Element.Position = Position

    return Element
end

function UiElement:SetValue()
end

function UiElement:GetValue()
    return self.Value
end

local Config = {}

Config.PrimaryColor = Color3.fromRGB(27, 38, 59)
Config.SecondaryColor = Color3.fromRGB(13, 27, 42)
Config.AccentColor = Color3.fromRGB(41, 115, 115)
Config.TextColor = Color3.new(1, 1, 1)
Config.Font = Enum.Font.Gotham
Config.TextSize = 13
Config.HeaderWidth = 300
Config.HeaderHeight = 32
Config.EntryMargin = 1
Config.AnimationDuration = 0.4
Config.AnimationEasingStyle = Enum.EasingStyle.Quint
Config.DefaultEntryHeight = 35

local CollapseButton = {}
CollapseButton.__index = CollapseButton
setmetatable(CollapseButton, UiElement)

function CollapseButton:New()
    local ButtonInstance = setmetatable(
        UiElement:New(UDim2.new(0, 20, 0, 20), UDim2.new(1, -20 - 5, 0.5, -20 / 2), ""),
        CollapseButton
    )

    ButtonInstance.GuiObject = Instance.new("TextButton")

    ButtonInstance.GuiObject.MouseButton1Click:Connect(function()
        ButtonInstance.Parent.Parent.Collapsed = not ButtonInstance.Parent.Parent.Collapsed

        if ButtonInstance.Parent.Parent.Collapsed then
            ButtonInstance.Parent.Parent:Collapse()
        else
            ButtonInstance.Parent.Parent:Expand()
        end
    end)

    return ButtonInstance
end

function CollapseButton:Collapse()
    self.GuiObject.Text = "+"
end

function CollapseButton:Expand()
    self.GuiObject.Text = "-"
end

function CollapseButton:UpdateGui()
    self.GuiObject.TextScaled = true
    self.GuiObject.TextColor3 = Config.TextColor
    self.GuiObject.BackgroundTransparency = 1
    self.GuiObject.Size = self.Size
    self.GuiObject.Position = self.Position

    if self.Parent.Parent.Collapsed then
        self.GuiObject.Text = "+"
    else
        self.GuiObject.Text = "-"
    end
end

local Header = {}
Header.__index = Header
setmetatable(Header, Node)

function Header:New(Title)
    local HeaderInstance = setmetatable(Node:New(NodeType.Header), Header)

    HeaderInstance.GuiObject = Instance.new("TextLabel")
    HeaderInstance.CollapseButton = CollapseButton:New()
    HeaderInstance:AddChild(HeaderInstance.CollapseButton)

    return HeaderInstance
end

function Header:UpdateGui()
    self.GuiObject.Size = UDim2.new(1, 0, 0, Config.HeaderHeight)
    self.GuiObject.Text = self.Parent.Title
    self.GuiObject.TextSize = Config.TextSize * 1.25
    self.GuiObject.TextColor3 = Config.TextColor
    self.GuiObject.Font = Config.Font
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.BackgroundColor3 = Config.SecondaryColor

    if self.Parent.Type == NodeType.Category then
        self.TextSize = Config.TextSize * 1.5
    end
end

local Entry = {}
Entry.__index = Entry
setmetatable(Entry, Node)

function Entry:New(Height)
    local EntryInstance = setmetatable(Node:New(NodeType.Entry), Entry)

    EntryInstance.Value = nil
    EntryInstance.Height = Height or Config.DefaultEntryHeight
    EntryInstance.GuiObject = Instance.new("Frame")

    return EntryInstance
end

function Entry:SetValue()
end

function Entry:GetValue()
end

function Entry:UpdateGui()
    self.GuiObject.BackgroundColor3 = Config.PrimaryColor
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.Size = UDim2.new(1, 0, 0, self.Height)
end

local Container = {}
Container.__index = Container
setmetatable(Container, Node)

function Container:New(Title, Type)
    local ContainerInstance = setmetatable(Node:New(Type), Container)

    ContainerInstance.Collapsed = false
    ContainerInstance.Height = 0
    ContainerInstance.GuiObject = Instance.new("Frame")
    ContainerInstance.Header = Header:New()
    ContainerInstance.Title = Title or ""
    ContainerInstance:AddChild(ContainerInstance.Header)

    return ContainerInstance
end

function Container:UpdateGui()
    self.GuiObject.Size = UDim2.new(0, Config.HeaderWidth, 0, 0)
    self.GuiObject.BackgroundColor3 = Config.SecondaryColor
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.ClipsDescendants = true
    self:ReorderGui(true)
end

function Container:ReorderGui(Instant)
    Instant = Instant or false

    local Duration = Config.AnimationDuration

    if Instant then
        Duration = 0
    end

    self.Height = Config.HeaderHeight

    if not self.Collapsed then
        for Index, Child in pairs(self.Children) do
            if Child.Type ~= NodeType.Header then
                Child.GuiObject:TweenPosition(
                    UDim2.new(0, 0, 0, self.Height),
                    Enum.EasingDirection.InOut,
                    Config.AnimationEasingStyle,
                    Duration,
                    true
                )

                self.Height = self.Height + Child.Height + Config.EntryMargin
            end
        end

        self.Height = self.Height - Config.EntryMargin
    end

    self.GuiObject:TweenSize(
        UDim2.new(0, Config.HeaderWidth, 0, self.Height),
        Enum.EasingDirection.InOut,
        Config.AnimationEasingStyle,
        Duration,
        true
    )

    if self.Parent.Type ~= NodeType.Root then
        self.Parent:ReorderGui(Instant)
    end
end

function Container:Collapse()
    self.Collapsed = true
    self.Header.CollapseButton:Collapse()
    self:ReorderGui()
end

function Container:Expand()
    self.Collapsed = false
    self.Header.CollapseButton:Expand()
    self:ReorderGui()
end

function Container:AddEntry(EntryInstance)
    self:AddChild(EntryInstance)
    EntryInstance:RecursiveUpdateGui()
    self:ReorderGui(true)
end

local Section = {}
Section.__index = Section
setmetatable(Section, Container)

function Section:New(Title)
    local SectionInstance = setmetatable(Container:New(Title, NodeType.Section), Section)

    return SectionInstance
end

function Container:CreateSection(Title)
    local SectionInstance = Section:New(Title)

    self:AddChild(SectionInstance)
    SectionInstance:RecursiveUpdateGui()

    return SectionInstance
end

local CategoryInputService = game:GetService("UserInputService")

local Category = {}
Category.__index = Category
setmetatable(Category, Container)

function Category:New(Title, Draggable)
    local CategoryInstance = setmetatable(Container:New(Title, NodeType.Category), Category)

    CategoryInstance.Draggable = Draggable or true
    CategoryInstance.Position = UDim2.new(0, 0, 0)
    CategoryInstance:ApplyDraggability()

    return CategoryInstance
end

function Category:MoveTo(Position)
    self.Position = Position
    self.GuiObject.Position = Position
end

function Category:AutoMove()
    self:MoveTo(UDim2.fromOffset(100 + (#self.Parent.Children - 1) * (Config.HeaderWidth * 1.25), 36))
end

function Category:ApplyDraggability()
    self.LastMousePosition = CategoryInputService:GetMouseLocation()
    self.DragActive = false

    self.Header.GuiObject.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 and self.Draggable then
            self.DragActive = true
        end
    end)

    self.Header.GuiObject.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.DragActive = false
        end
    end)

    CategoryInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            if self.DragActive then
                local MouseDelta = CategoryInputService:GetMouseLocation() - self.LastMousePosition

                self:MoveTo(UDim2.new(
                    self.GuiObject.Position.X.Scale,
                    self.GuiObject.Position.X.Offset + MouseDelta.X,
                    self.GuiObject.Position.Y.Scale,
                    self.GuiObject.Position.Y.Offset + MouseDelta.Y
                ))
            end

            self.LastMousePosition = CategoryInputService:GetMouseLocation()
        end
    end)
end

local Button = {}
Button.__index = Button
setmetatable(Button, UiElement)

function Button:New(Size, Position, Title, Callback)
    local ButtonInstance = setmetatable(UiElement:New(Size, Position, Title), Button)

    ButtonInstance.Callback = Callback
    ButtonInstance.GuiObject = Instance.new("TextButton")
    ButtonInstance.GuiObject.MouseButton1Click:Connect(ButtonInstance.Callback)

    return ButtonInstance
end

function Button:UpdateGui()
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.BackgroundColor3 = Config.SecondaryColor
    self.GuiObject.TextColor3 = Config.TextColor
    self.GuiObject.Size = self.Size
    self.GuiObject.Position = self.Position
    self.GuiObject.Text = self.Title
    self.GuiObject.TextSize = Config.TextSize
    self.GuiObject.Font = Config.Font
end

function Container:CreateButton(Title, Callback)
    local EntryInstance = Entry:New()

    EntryInstance:AddChild(Button:New(UDim2.new(1, -10, 1, -10), UDim2.new(0, 5, 0, 5), Title, Callback))
    self:AddEntry(EntryInstance)

    return EntryInstance
end

local SliderInputService = game:GetService("UserInputService")

local Slider = {}
Slider.__index = Slider
setmetatable(Slider, UiElement)

function Slider:New(Size, Position, Title, Callback, Min, Max, Step, Dynamic, Value, CustomColor)
    local SliderInstance = setmetatable(UiElement:New(Size, Position, Title), Slider)

    SliderInstance.Callback = Callback
    SliderInstance.Dynamic = Dynamic or false
    Value = Value or Min
    SliderInstance.Step = Step or 0.01
    SliderInstance.Max = Max
    SliderInstance.Min = Min
    SliderInstance.CustomColor = CustomColor
    SliderInstance.Value = Value or SliderInstance.Min
    SliderInstance.GuiObject = Instance.new("Frame")
    SliderInstance.Bg = Instance.new("Frame", SliderInstance.GuiObject)
    SliderInstance.Box = Instance.new("TextBox", SliderInstance.GuiObject)
    SliderInstance.Overlay = Instance.new("Frame", SliderInstance.Bg)
    SliderInstance.Handle = Instance.new("Frame", SliderInstance.Overlay)
    SliderInstance.Label = Instance.new("TextLabel", SliderInstance.Bg)
    SliderInstance.Active = false

    SliderInstance.Bg.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            SliderInstance.Active = true

            local Fraction = math.clamp(
                Input.Position.X - SliderInstance.Bg.AbsolutePosition.X,
                0,
                SliderInstance.Bg.AbsoluteSize.X
            ) / SliderInstance.Bg.AbsoluteSize.X

            SliderInstance:SetValue(SliderInstance.Min + (Fraction * (SliderInstance.Max - SliderInstance.Min)))
        end
    end)

    SliderInstance.Bg.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            SliderInstance.Active = false
            SliderInstance.Callback(SliderInstance.Value)
        end
    end)

    SliderInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            if SliderInstance.Active then
                local Fraction = math.clamp(
                    Input.Position.X - SliderInstance.Bg.AbsolutePosition.X,
                    0,
                    SliderInstance.Bg.AbsoluteSize.X
                ) / SliderInstance.Bg.AbsoluteSize.X

                SliderInstance:SetValue(SliderInstance.Min + (Fraction * (SliderInstance.Max - SliderInstance.Min)))

                if SliderInstance.Dynamic then
                    SliderInstance.Callback(SliderInstance.Value)
                end
            end
        end
    end)

    SliderInstance.Box.FocusLost:Connect(function()
        local Value = tonumber(SliderInstance.Box.Text)

        if Value then
            SliderInstance:SetValue(Value)
            SliderInstance.Callback(SliderInstance.Value)
        else
            SliderInstance.Box.Text = SliderInstance.Value
        end
    end)

    return SliderInstance
end

function Slider:SetValue(Value)
    self.Value = math.clamp(Value - Value % self.Step, self.Min, self.Max)
    self.Overlay.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
    self.Box.Text = tostring(self.Value)
end

function Slider:UpdateGui()
    self.GuiObject.BackgroundColor3 = Config.SecondaryColor
    self.GuiObject.Size = self.Size
    self.GuiObject.Position = self.Position
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.BackgroundTransparency = 1

    self.Bg.BorderSizePixel = 0
    self.Bg.Size = UDim2.new(1 - 0.2, 0, 1, 0)
    self.Bg.BackgroundColor3 = Config.SecondaryColor

    self.Box.Size = UDim2.new(0.2, -5, 1, 0)
    self.Box.Position = UDim2.new(0.8, 5, 0, 0)
    self.Box.BorderSizePixel = 0
    self.Box.BackgroundColor3 = Config.SecondaryColor
    self.Box.TextColor3 = Config.TextColor
    self.Box.TextWrapped = true

    self.Overlay.BorderSizePixel = 0
    self.Overlay.BackgroundColor3 = self.CustomColor or Config.AccentColor

    self.Handle.Size = UDim2.new(0, 5, 1, 0)
    self.Handle.Position = UDim2.new(1, -(5 / 2), 0, 0)
    self.Handle.BackgroundColor3 = Color3.new(1, 1, 1)
    self.Handle.BorderSizePixel = 0

    self.Label.Text = self.Title
    self.Label.Font = Config.Font
    self.Label.TextSize = Config.TextSize
    self.Label.BackgroundTransparency = 1
    self.Label.Size = UDim2.new(1, 0, 1, 0)
    self.Label.TextColor3 = Config.TextColor

    self:SetValue(self.Value)
end

local SliderEntry = {}
SliderEntry.__index = SliderEntry
setmetatable(SliderEntry, Entry)

function SliderEntry:New(Title, Callback, Min, Max, Step, Dynamic, Value)
    local EntryInstance = setmetatable(Entry:New(), SliderEntry)

    EntryInstance.Slider = Slider:New(
        UDim2.new(1, -10, 1, -14),
        UDim2.new(0, 5, 0, 7),
        Title,
        function(SliderValue)
            EntryInstance.Value = SliderValue
            pcall(Callback, EntryInstance.Value)
        end,
        Min,
        Max,
        Step,
        Dynamic,
        Value
    )

    EntryInstance:SetValue(Value or EntryInstance:GetValue())
    EntryInstance:AddChild(EntryInstance.Slider)

    return EntryInstance
end

function SliderEntry:SetValue(Value)
    self.Slider:SetValue(Value)
end

function SliderEntry:GetValue()
    return self.Slider.Value
end

function Container:CreateSlider(Title, Callback, Min, Max, Step, Dynamic, Value)
    local EntryInstance = SliderEntry:New(Title, Callback, Min, Max, Step, Dynamic, Value)

    self:AddEntry(EntryInstance)

    return EntryInstance
end

local TextBoxInputService = game:GetService("UserInputService")

local TextBox = {}
TextBox.__index = TextBox
setmetatable(TextBox, UiElement)

function TextBox:New(Size, Position, Title, Callback, AcceptFormat, Dynamic, Value)
    local TextBoxInstance = setmetatable(UiElement:New(Size, Position, Title), TextBox)

    TextBoxInstance.Callback = Callback
    TextBoxInstance.Dynamic = Dynamic or false
    TextBoxInstance.Value = Value or ""
    TextBoxInstance.AcceptFormat = AcceptFormat or "^.*$"
    TextBoxInstance.GuiObject = Instance.new("TextBox")

    TextBoxInstance.GuiObject.FocusLost:Connect(function()
        if string.match(TextBoxInstance.GuiObject.Text, TextBoxInstance.AcceptFormat) then
            TextBoxInstance:SetValue(TextBoxInstance.GuiObject.Text)
            TextBoxInstance.Callback(TextBoxInstance.Value)
        else
            TextBoxInstance.GuiObject.Text = TextBoxInstance.Value
        end
    end)

    TextBoxInstance.GuiObject.Changed:Connect(function(Property)
        if TextBoxInstance.Dynamic and Property == "Text" and TextBoxInstance.GuiObject:IsFocused() then
            if string.match(TextBoxInstance.GuiObject.Text, TextBoxInstance.AcceptFormat) then
                TextBoxInstance:SetValue(TextBoxInstance.GuiObject.Text)
                TextBoxInstance.Callback(TextBoxInstance.Value)
            else
                TextBoxInstance.GuiObject.Text = TextBoxInstance.Value
            end
        end
    end)

    return TextBoxInstance
end

function TextBox:SetValue(Value)
    self.GuiObject.Text = Value
    self.Value = Value
end

function TextBox:UpdateGui()
    self.GuiObject.BackgroundColor3 = Config.SecondaryColor
    self.GuiObject.TextColor3 = Config.TextColor
    self.GuiObject.PlaceholderText = self.Title
    self.GuiObject.Position = self.Position
    self.GuiObject.Size = self.Size
    self.GuiObject.TextSize = Config.TextSize
    self.GuiObject.Font = Config.Font
    self.GuiObject.BorderSizePixel = 0
    self:SetValue(self.Value)
end

local TextBoxEntry = {}
TextBoxEntry.__index = TextBoxEntry
setmetatable(TextBoxEntry, Entry)

function TextBoxEntry:New(Title, Callback, AcceptFormat, Dynamic, Value)
    local EntryInstance = setmetatable(Entry:New(), TextBoxEntry)

    EntryInstance.TextBox = TextBox:New(
        UDim2.new(1, -10, 1, -10),
        UDim2.new(0, 5, 0, 5),
        Title,
        Callback,
        AcceptFormat,
        Dynamic,
        Value
    )

    EntryInstance:AddChild(EntryInstance.TextBox)

    return EntryInstance
end

function TextBoxEntry:SetValue(Value)
    self.TextBox:SetValue(Value)
end

function TextBoxEntry:GetValue()
    return self.TextBox.Value
end

function Container:CreateTextBox(Title, Callback, AcceptFormat, Dynamic, Value)
    local EntryInstance = TextBoxEntry:New(Title, Callback, AcceptFormat, Dynamic, Value)

    self:AddEntry(EntryInstance)

    return EntryInstance
end

local ColorPickerInputService = game:GetService("UserInputService")

local ColorPicker = {}
ColorPicker.__index = ColorPicker
setmetatable(ColorPicker, UiElement)

function ColorPicker:New(Size, Position, Title, Callback, DefaultColor, Dynamic, Value)
    local PickerInstance = setmetatable(UiElement:New(Size, Position, Title), ColorPicker)

    PickerInstance.Callback = Callback
    PickerInstance.Dynamic = Dynamic or false
    PickerInstance.Value = Value or Config.AccentColor
    PickerInstance.GuiObject = Instance.new("Frame")
    PickerInstance.ColorImg = Instance.new("ImageLabel", PickerInstance.GuiObject)
    PickerInstance.Cursor = Instance.new("Frame", PickerInstance.ColorImg)

    PickerInstance.RSlider = Slider:New(
        UDim2.new(0.5, -10, 1 / 6, 0),
        UDim2.new(0.5, 5, 0 / 6, 2),
        "Red",
        function(Value)
            PickerInstance:SetValue(Color3.new(Value / 255, PickerInstance.Value.G, PickerInstance.Value.B))
        end,
        0,
        255,
        1,
        true,
        PickerInstance.Value.R,
        Color3.new(0.75, 0, 0)
    )

    PickerInstance:AddChild(PickerInstance.RSlider)

    PickerInstance.GSlider = Slider:New(
        UDim2.new(0.5, -10, 1 / 6, 0),
        UDim2.new(0.5, 5, 1 / 6, 4),
        "Green",
        function(Value)
            PickerInstance:SetValue(Color3.new(PickerInstance.Value.R, Value / 255, PickerInstance.Value.B))
        end,
        0,
        255,
        1,
        true,
        PickerInstance.Value.G,
        Color3.new(0, 0.75, 0)
    )

    PickerInstance:AddChild(PickerInstance.GSlider)

    PickerInstance.BSlider = Slider:New(
        UDim2.new(0.5, -10, 1 / 6, 0),
        UDim2.new(0.5, 5, 2 / 6, 6),
        "Blue",
        function(Value)
            PickerInstance:SetValue(Color3.new(PickerInstance.Value.R, PickerInstance.Value.G, Value / 255))
        end,
        0,
        255,
        1,
        true,
        PickerInstance.Value.B,
        Color3.new(0, 0, 0.75)
    )

    PickerInstance:AddChild(PickerInstance.BSlider)

    PickerInstance.HexBox = TextBox:New(
        UDim2.new(0.5, -10, 1 / 6, 0),
        UDim2.new(0.5, 5, 3 / 6, 8),
        "",
        function(HexValue)
            local Channels = {}

            for Channel in HexValue:gmatch("%x%x") do
                table.insert(Channels, tonumber("0x" .. Channel))
            end

            PickerInstance:SetValue(Color3.fromRGB(unpack(Channels)))
        end,
        "^%x%x%x%x%x%x$"
    )

    PickerInstance:AddChild(PickerInstance.HexBox)

    PickerInstance.VSlider = Slider:New(
        UDim2.new(0.5, -10, 1 / 6, 0),
        UDim2.new(0.5, 5, 5 / 6, -2),
        "Value",
        function(Value)
            local Hue, Saturation = Color3.toHSV(PickerInstance.Value)

            PickerInstance:SetValue(Color3.fromHSV(Hue, Saturation, Value / 255))
        end,
        0,
        255,
        1,
        true,
        ({ Color3.toHSV(PickerInstance.Value) })[3],
        Color3.new(0.75, 0.75, 0.75)
    )

    PickerInstance:AddChild(PickerInstance.VSlider)

    PickerInstance.ColorImg.MouseMoved:Connect(function(MouseX, MouseY)
        if ColorPickerInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local MousePosition = Vector2.new(MouseX, MouseY - 36) - PickerInstance.ColorImg.AbsolutePosition
            local Hue, Saturation =
                1 - MousePosition.X / PickerInstance.ColorImg.AbsoluteSize.X,
                1 - MousePosition.Y / PickerInstance.ColorImg.AbsoluteSize.Y

            PickerInstance:SetValue(Color3.fromHSV(Hue, Saturation, PickerInstance.VSlider.Value / 255))
        end
    end)

    PickerInstance.ColorImg.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local MousePosition = Vector2.new(Input.Position.X, Input.Position.Y) - PickerInstance.ColorImg.AbsolutePosition
            local Hue, Saturation =
                1 - MousePosition.X / PickerInstance.ColorImg.AbsoluteSize.X,
                1 - MousePosition.Y / PickerInstance.ColorImg.AbsoluteSize.Y

            PickerInstance:SetValue(Color3.fromHSV(Hue, Saturation, PickerInstance.VSlider.Value / 255))
        end
    end)

    PickerInstance:SetValue(PickerInstance.Value)

    return PickerInstance
end

function ColorPicker:SetValue(Value)
    self.Value = Value

    local Hue, Saturation, Brightness = Color3.toHSV(Value)

    self.Cursor.Position = UDim2.new(1 - Hue, -2, 1 - Saturation, -2)
    self.VSlider:SetValue(Brightness * 255)
    self.RSlider:SetValue(Value.R * 255)
    self.GSlider:SetValue(Value.G * 255)
    self.BSlider:SetValue(Value.B * 255)
    self.HexBox:SetValue(string.format("%02x%02x%02x", self.Value.R * 255, self.Value.G * 255, self.Value.B * 255))
    self.Callback(self.Value)
end

function ColorPicker:UpdateGui()
    self.GuiObject.Size = self.Size
    self.GuiObject.Position = self.Position
    self.GuiObject.BackgroundTransparency = 1

    self.ColorImg.Image = "rbxassetid://698052001"
    self.ColorImg.Size = UDim2.new(0.5, -10, 1, -10)
    self.ColorImg.BorderSizePixel = 0
    self.ColorImg.Position = UDim2.new(0, 5, 0, 5)

    self.Cursor.Size = UDim2.new(0, 4, 0, 4, 0)
    self.Cursor.BorderSizePixel = 0
    self.Cursor.BackgroundColor3 = Color3.new(1, 1, 1)

    self:SetValue(self.Value)
end

local ColorPickerEntry = {}
ColorPickerEntry.__index = ColorPickerEntry
setmetatable(ColorPickerEntry, Entry)

function ColorPickerEntry:New(Title, Callback, Dynamic, Value)
    local EntryInstance = setmetatable(Entry:New(), ColorPickerEntry)

    EntryInstance.Title = Title
    EntryInstance.Dynamic = Dynamic
    EntryInstance.Callback = Callback
    EntryInstance.Label = Instance.new("TextLabel", EntryInstance.GuiObject)
    EntryInstance.ColorButton = Instance.new("TextButton", EntryInstance.Label)

    EntryInstance.ColorPicker = ColorPicker:New(
        UDim2.new(1, 0, 0, Config.HeaderWidth / 2),
        UDim2.new(0, 0, 0, Config.DefaultEntryHeight),
        Title,
        function(Color)
            EntryInstance.ColorButton.BackgroundColor3 = Color
            EntryInstance.Value = Color

            if EntryInstance.Dynamic and EntryInstance.Toggled then
                pcall(EntryInstance.Callback, Color)
            end
        end,
        Value
    )

    EntryInstance.Toggled = false

    EntryInstance.ColorButton.MouseButton1Click:Connect(function()
        if EntryInstance.Toggled then
            EntryInstance.Height = Config.DefaultEntryHeight
            pcall(Callback, EntryInstance.Value)
        else
            EntryInstance.Height = Config.HeaderWidth / 2 + Config.DefaultEntryHeight
        end

        EntryInstance.GuiObject:TweenSize(
            UDim2.new(1, 0, 0, EntryInstance.Height),
            Enum.EasingDirection.InOut,
            Config.AnimationEasingStyle,
            Config.AnimationDuration,
            true
        )

        EntryInstance.Parent:ReorderGui()
        EntryInstance.Toggled = not EntryInstance.Toggled
    end)

    EntryInstance:SetValue(Value or EntryInstance:GetValue())
    EntryInstance:AddChild(EntryInstance.ColorPicker)

    return EntryInstance
end

function ColorPickerEntry:SetValue(Value)
    self.ColorPicker:SetValue(Value)
end

function ColorPickerEntry:GetValue()
    return self.ColorPicker.Value
end

function ColorPickerEntry:UpdateGui()
    self.Label.Size = UDim2.new(1, -16, 0, Config.DefaultEntryHeight)
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Font = Config.Font
    self.Label.Text = self.Title

    self.GuiObject.ClipsDescendants = true
    self.GuiObject.BackgroundColor3 = Config.PrimaryColor
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.Size = UDim2.new(1, 0, 0, self.Height)

    self.Label.TextSize = Config.TextSize
    self.Label.TextColor3 = Config.TextColor

    self.ColorButton.Size = UDim2.new(0, 16, 0, 16, 0)
    self.ColorButton.Position = UDim2.new(1, -37, 0.5, -8)
    self.ColorButton.Text = ""
    self.ColorButton.AutoButtonColor = false
end

function Container:CreateColorPicker(Title, Callback, Dynamic, Value)
    local EntryInstance = ColorPickerEntry:New(Title, Callback, Dynamic, Value)

    self:AddEntry(EntryInstance)
    EntryInstance:RecursiveUpdateGui()

    return EntryInstance
end

local SelectorInputService = game:GetService("UserInputService")

local function FilterList(Items, Query)
    local Matches = {}

    for Index, Item in pairs(Items) do
        if string.match(string.lower(tostring(Item)), string.lower(Query)) then
            table.insert(Matches, Item)
        end
    end

    return Matches
end

local Selector = {}
Selector.__index = Selector
setmetatable(Selector, UiElement)

function Selector:New(Size, Position, Title, Callback, GetItems)
    local SelectorInstance = setmetatable(UiElement:New(Size, Position, Title), Selector)

    SelectorInstance.Callback = Callback
    SelectorInstance.Getcall = GetItems
    SelectorInstance.GuiObject = Instance.new("Frame")
    SelectorInstance.ScrollBox = Instance.new("ScrollingFrame", SelectorInstance.GuiObject)

    SelectorInstance.SearchBox = TextBox:New(
        UDim2.new(1, 0, 0, 30),
        UDim2.new(0, 0, 0, 0),
        "Search",
        function(Query)
            SelectorInstance:SetList(FilterList(GetItems(), Query))
        end,
        nil,
        true
    )

    SelectorInstance:AddChild(SelectorInstance.SearchBox)

    return SelectorInstance
end

function Selector:SetList(Items)
    local RowIndex = 0

    self.ScrollBox:ClearAllChildren()

    for Index, Item in pairs(Items) do
        local ItemButton = Instance.new("TextButton", self.ScrollBox)

        ItemButton.Text = tostring(Item)
        ItemButton.BackgroundColor3 = Config.SecondaryColor
        ItemButton.TextColor3 = Config.TextColor
        ItemButton.BorderColor3 = Config.PrimaryColor
        ItemButton.Size = UDim2.new(1, -4, 0, 30)
        ItemButton.Position = UDim2.new(0, 2, 0, ItemButton.AbsoluteSize.Y * (RowIndex))

        ItemButton.MouseButton1Click:Connect(function()
            self.Callback(Item)
            self:SetList(FilterList(self.Getcall(), self.SearchBox.Value))
        end)

        RowIndex = RowIndex + 1
    end

    self.ScrollBox.CanvasSize = UDim2.new(0, 0, 0, #Items * 30)
end

function Selector:UpdateGui()
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.BackgroundTransparency = 1
    self.GuiObject.Size = self.Size
    self.GuiObject.Position = self.Position

    self.ScrollBox.Position = UDim2.new(0, 0, 0, 30 + 2)
    self.ScrollBox.BackgroundTransparency = 1
    self.ScrollBox.BorderSizePixel = 0
    self.ScrollBox.ScrollBarThickness = 3
    self.ScrollBox.Size = UDim2.new(1, 0, 1, -30)

    self:SetList(self.Getcall())
end

local SelectorEntry = {}
SelectorEntry.__index = SelectorEntry
setmetatable(SelectorEntry, Entry)

function SelectorEntry:New(Title, Callback, GetItems, Value)
    local EntryInstance = setmetatable(Entry:New(), SelectorEntry)

    EntryInstance.Title = Title
    EntryInstance.Callback = Callback

    EntryInstance.Selector = Selector:New(
        UDim2.new(1, 0, 0, Config.DefaultEntryHeight * 5),
        UDim2.new(0, 0, 0, Config.DefaultEntryHeight),
        Title,
        function(Item)
            if not SelectorInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                EntryInstance:Toggle()
            end

            EntryInstance:SetValue(Item)
            EntryInstance.Callback(Item)
        end,
        GetItems
    )

    EntryInstance:AddChild(EntryInstance.Selector)
    EntryInstance.Button = Instance.new("TextButton", EntryInstance.GuiObject)
    EntryInstance.Indicator = Instance.new("TextLabel", EntryInstance.Button)
    EntryInstance.Indicator.Text = "▼"
    EntryInstance.Toggled = false

    EntryInstance.Button.MouseButton1Click:Connect(function()
        EntryInstance:Toggle()
        EntryInstance.Selector:SetList(FilterList(EntryInstance.Selector.Getcall(), EntryInstance.Selector.SearchBox.Value))
    end)

    EntryInstance:SetValue(Value)

    return EntryInstance
end

function SelectorEntry:Toggle()
    if self.Toggled then
        self.Height = Config.DefaultEntryHeight
        self.Indicator.Text = "▼"
    else
        self.Height = Config.DefaultEntryHeight * 6
        self.Indicator.Text = "▲"
    end

    self.GuiObject:TweenSize(
        UDim2.new(1, 0, 0, self.Height),
        Enum.EasingDirection.InOut,
        Config.AnimationEasingStyle,
        Config.AnimationDuration,
        true
    )

    self.Parent:ReorderGui()
    self.Toggled = not self.Toggled
end

function SelectorEntry:SetValue(Value)
    self.Button.Text = string.format("%s [%s]", self.Title, tostring(Value or "Empty"))
    self.Value = Value
end

function SelectorEntry:GetValue()
    return self.Value
end

function SelectorEntry:UpdateGui()
    self.GuiObject.ClipsDescendants = true
    self.GuiObject.BackgroundColor3 = Config.PrimaryColor
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.Size = UDim2.new(1, 0, 0, self.Height)

    self.Button.Position = UDim2.new(0, 5, 0, 5)
    self.Button.BorderSizePixel = 0
    self.Button.Font = Config.Font
    self.Button.TextSize = Config.TextSize
    self.Button.Size = UDim2.new(1, -10, 0, self.Height - 10)
    self.Button.BackgroundColor3 = Config.SecondaryColor
    self.Button.TextColor3 = Config.TextColor
    self.Button.AutoButtonColor = false

    self.Indicator.Size = UDim2.new(0, 20, 0, 20)
    self.Indicator.Position = UDim2.new(0, 0, 0.5, -10)
    self.Indicator.BackgroundTransparency = 1
    self.Indicator.TextColor3 = Config.TextColor
end

function Container:CreateSelector(Title, Callback, GetItems, Value)
    local EntryInstance = SelectorEntry:New(Title, Callback, GetItems, Value)

    self:AddEntry(EntryInstance)

    return EntryInstance
end

local SwitchInputService = game:GetService("UserInputService")

local Switch = {}
Switch.__index = Switch
setmetatable(Switch, UiElement)

function Switch:New(Size, Position, Title, Callback, Value)
    local SwitchInstance = setmetatable(UiElement:New(Size, Position, Title), Switch)

    SwitchInstance.Callback = Callback
    SwitchInstance.Value = Value or false
    SwitchInstance.GuiObject = Instance.new("Frame")
    SwitchInstance.Label = Instance.new("TextLabel", SwitchInstance.GuiObject)
    SwitchInstance.Button = Instance.new("TextButton", SwitchInstance.GuiObject)

    SwitchInstance.Button.MouseButton1Click:Connect(function()
        SwitchInstance:SetValue(not SwitchInstance.Value)
        SwitchInstance.Callback(SwitchInstance.Value)
    end)

    return SwitchInstance
end

function Switch:SetValue(Value)
    self.Value = Value

    if self.Value then
        self.Button.BackgroundColor3 = Config.AccentColor
    else
        self.Button.BackgroundColor3 = Config.SecondaryColor
    end
end

function Switch:UpdateGui()
    self.GuiObject.Size = self.Size
    self.GuiObject.BackgroundTransparency = 1
    self.GuiObject.Position = self.Position

    self.Label.Text = self.Title
    self.Label.TextSize = Config.TextSize
    self.Label.Font = Config.Font
    self.Label.BackgroundTransparency = 1
    self.Label.Size = UDim2.new(0.8, 0, 1, 0)
    self.Label.TextColor3 = Config.TextColor

    self.Button.Size = UDim2.new(0, 20, 0, 20)
    self.Button.BorderSizePixel = 2
    self.Button.BorderColor3 = Config.SecondaryColor
    self.Button.Position = UDim2.new(0.9, -10, 0.5, -10)
    self.Button.Text = ""

    self:SetValue(self.Value)
end

local SwitchEntry = {}
SwitchEntry.__index = SwitchEntry
setmetatable(SwitchEntry, Entry)

function SwitchEntry:New(Title, Callback, Value)
    local EntryInstance = setmetatable(Entry:New(), SwitchEntry)

    EntryInstance.Switch = Switch:New(
        UDim2.new(1, -10, 1, -10),
        UDim2.new(0, 5, 0, 5),
        Title,
        Callback,
        Value
    )

    EntryInstance:AddChild(EntryInstance.Switch)

    return EntryInstance
end

function SwitchEntry:SetValue(Value)
    self.Switch:SetValue(Value)
end

function SwitchEntry:GetValue()
    return self.Switch.Value
end

function Container:CreateSwitch(Title, Callback, Value)
    local EntryInstance = SwitchEntry:New(Title, Callback, Value)

    self:AddEntry(EntryInstance)

    return EntryInstance
end

local TextLabel = {}
TextLabel.__index = TextLabel
setmetatable(TextLabel, UiElement)

function TextLabel:New(Size, Position, Title)
    local LabelInstance = setmetatable(UiElement:New(Size, Position, Title), TextLabel)

    LabelInstance.GuiObject = Instance.new("TextLabel")

    return LabelInstance
end

function TextLabel:UpdateGui()
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.BackgroundTransparency = 1
    self.GuiObject.TextColor3 = Config.TextColor
    self.GuiObject.Size = self.Size
    self.GuiObject.Position = self.Position
    self.GuiObject.Text = self.Title
    self.GuiObject.TextSize = Config.TextSize
    self.GuiObject.Font = Config.Font
end

function Container:CreateTextLabel(Title)
    local EntryInstance = Entry:New()

    EntryInstance:AddChild(TextLabel:New(UDim2.new(1, -10, 1, -10), UDim2.new(0, 5, 0, 5), Title))
    self:AddEntry(EntryInstance)

    return EntryInstance
end

local KeyDetectorInputService = game:GetService("UserInputService")

local KeyDetector = {}
KeyDetector.__index = KeyDetector
setmetatable(KeyDetector, UiElement)

function KeyDetector:New(Size, Position, Title, Callback, Value)
    local DetectorInstance = setmetatable(UiElement:New(Size, Position, Title), KeyDetector)

    DetectorInstance.Callback = Callback
    DetectorInstance.Value = Value or Enum.KeyCode.Unknown
    DetectorInstance.GuiObject = Instance.new("Frame")
    DetectorInstance.Label = Instance.new("TextLabel", DetectorInstance.GuiObject)
    DetectorInstance.Button = Instance.new("TextButton", DetectorInstance.GuiObject)

    DetectorInstance.Button.MouseButton1Click:Connect(function()
        DetectorInstance.Button.Text = "..."

        local Input

        repeat
            Input = KeyDetectorInputService.InputBegan:Wait()
        until Input.UserInputType == Enum.UserInputType.Keyboard

        DetectorInstance:SetValue(Input.KeyCode)
        DetectorInstance.Callback(DetectorInstance.Value)
    end)

    return DetectorInstance
end

function KeyDetector:SetValue(Value)
    self.Value = Value
    self.Button.Text = Value.Name
end

function KeyDetector:UpdateGui()
    self.GuiObject.BackgroundTransparency = 1
    self.GuiObject.Size = self.Size
    self.GuiObject.Position = self.Position

    self.Label.Size = UDim2.new(0.8, 0, 1, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.TextSize = Config.TextSize
    self.Label.Text = self.Title
    self.Label.Font = Config.Font
    self.Label.TextColor3 = Config.TextColor

    self.Button.Size = UDim2.new(0.2, 0, 1, 0)
    self.Button.BorderSizePixel = 0
    self.Button.TextColor3 = Config.TextColor
    self.Button.BackgroundColor3 = Config.SecondaryColor
    self.Button.Position = UDim2.new(0.8, 0, 0, 0)

    self:SetValue(self.Value)
end

local KeyDetectorEntry = {}
KeyDetectorEntry.__index = KeyDetectorEntry
setmetatable(KeyDetectorEntry, Entry)

function KeyDetectorEntry:New(Title, Callback, Value)
    local EntryInstance = setmetatable(Entry:New(), KeyDetectorEntry)

    EntryInstance.KeyDetector = KeyDetector:New(
        UDim2.new(1, -10, 1, -10),
        UDim2.new(0, 5, 0, 5),
        Title,
        Callback,
        Value
    )

    EntryInstance:AddChild(EntryInstance.KeyDetector)

    return EntryInstance
end

function KeyDetectorEntry:SetValue(Value)
    self.KeyDetector:SetValue(Value)
end

function KeyDetectorEntry:GetValue()
    return self.KeyDetector.Value
end

function Container:CreateKeyDetector(Title, Callback, Value)
    local EntryInstance = KeyDetectorEntry:New(Title, Callback, Value)

    self:AddEntry(EntryInstance)

    return EntryInstance
end

local Library = {}
Library.__index = Library
setmetatable(Library, Node)

function Library:New(Parent)
    local LibraryInstance = setmetatable(Node:New(NodeType.Root), Library)

    LibraryInstance.ScreenGui = Instance.new("ScreenGui", Parent or game.Players.LocalPlayer.PlayerGui)
    LibraryInstance.GuiObject = Instance.new("Frame", LibraryInstance.ScreenGui)

    return LibraryInstance
end

function Library:UpdateGui()
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true
    self.GuiObject.Size = UDim2.new(1, 0, 1, 0)
    self.GuiObject.BackgroundTransparency = 1
end

function Library:Hide()
    self.ScreenGui.Enabled = false
end

function Library:Show()
    self.ScreenGui.Enabled = true
end

function Library:CleanUp()
    self.ScreenGui:Destroy()
    self = nil
end

function Library:CreateCategory(Title, Position)
    local CategoryInstance = Category:New(Title, Position)

    self:AddChild(CategoryInstance)

    if Position then
        CategoryInstance:MoveTo(Position)
    else
        CategoryInstance:AutoMove()
    end

    CategoryInstance:RecursiveUpdateGui()

    return CategoryInstance
end

function Library:LoadConfig(Overrides)
    for Key, Value in pairs(Overrides) do
        Config[Key] = Value
    end
end

function Library:Init(Overrides, Parent)
    local LibraryInstance = Library:New(Parent)

    LibraryInstance:LoadConfig(Overrides or {})
    LibraryInstance:RecursiveUpdateGui()

    return LibraryInstance
end

return Library
