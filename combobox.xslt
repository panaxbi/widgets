<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xo="http://panax.io/xover"
  xmlns:combobox="http://panax.io/widget/combobox"
>
	<xsl:template mode="combobox:widget" match="@*|*">
		<xsl:param name="dataset" select="."/>
		<xsl:param name="xo-context"/>
		<xsl:param name="xo-slot">
			<xsl:choose>
				<xsl:when test="self::*">combobox:selected</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="selected-value" select="(self::*[1]|current()[not(self::*)]/..)/@*[name()=$xo-slot]"/>
		<xsl:variable name="current" select="."/>
		<xsl:variable name="attribute"/>
		<style>
			<![CDATA[
			
			.dropdown.form-input > button.form-control::after {
				left: 1.25rem;
				border-width: 0 1px 1px 0 !important;
				scale: 1.5;
				margin: auto;
				position: relative;
			}
			
			.dropdown.form-input > .dropdown-menu {
				padding: 0;
				width: 100%;
				position: absolute;
				inset: 0px auto auto 0px;
				margin: 0px;/*
				transform: translate(0px, 0px);
				top: 57px !important;*/
				top: 100%;
			}
			
			option.hidden {
				display: none;
			}
			
			option.disabled {
				opacity: .65;
			}
			
			.dropdown.form-input input[type=text]:focus {
				color: silver !important
			}

			.combobox .dropdown-toggle:after {
				border: solid !important;
				border-width: 0 2px 2px 0 !important;
				display: inline-block !important;
				padding: 2px !important;
				transform: rotate( 45deg ) !important;
			}
			
			.combobox .dropdown-menu {
				box-shadow: var(--combobox-menu-boxshadow, var(--menu-boxshadow, 5px 5px 10px 2px rgb(0,0,0,.5)))
			}
			
			.combobox input[type=search]::-webkit-search-cancel-button {
				display: none;
			}
			
			.combobox [data-bs-toggle] [type=search]:focus {
				color: darkgray;
			}
			]]>
		</style>
		<div class="dropdown form-input form-control combobox" style="min-width: 19ch; display: flex; position: relative; flex: 1 1 auto; padding: 0; border: none !important;" xo-slot="{$xo-slot}">
			<xsl:attribute name="onmouseover">scope.dispatch('downloadCatalog')</xsl:attribute>
			<!--<xsl:variable name="options" select="$context|$schema/ancestor::px:Association[1]/@IsNullable[.=1]"/>-->
			<button class="btn btn-lg dropdown-toggle form-control" xo-static="@*" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="display:flex; padding: 0; background: transparent; padding-right: 2.5rem; top: 0;" tabindex="-1" onfocus="let input = this.querySelector('[type=search]'); input !== document.activeElement &amp;&amp; !input.justLostFocus &amp;&amp; this.querySelector('input').focus();">
				<div class="form-group input-group" style="min-width: calc(19ch + 6rem);border: none;">
					<input type="search" name="" class="form-control" autocomplete="off" aria-autocomplete="none" maxlength="" size="" value="{current()}" style="border: 0 solid transparent !important; background: transparent;" xo-slot="combobox:filter">
						<xsl:attribute name="value">
							<xsl:apply-templates mode="combobox:display-text" select="$selected-value|current()[not($selected-value)]">
								<xsl:with-param name="dataset" select="$dataset"/>
							</xsl:apply-templates>
						</xsl:attribute>
						<xsl:attribute name="onfocus">
							<xsl:text/>event.preventDefault(); this.value = scope.value || `<xsl:value-of select="current()"/>` || this.value;<xsl:text/>
						</xsl:attribute>
					</input>
				</div>
			</button>
			<ul class="dropdown-menu context" style="width: 100%;" aria-labelledby="dropdownMenuLink" xo-static="@* -@xo-scope">
				<select class="form-select data-rows" xo-static="@*" size="10" tabindex="-1" onchange="xo.components.combobox.change.call(this)">
					<xsl:apply-templates mode="combobox:option-clear" select="$selected-value"/>
					<xsl:apply-templates mode="combobox:option" select="$dataset">
						<xsl:with-param name="selected-value" select="$selected-value"/>
					</xsl:apply-templates>
					<!--<xsl:attribute name="style">
						<xsl:text/>min-width:<xsl:value-of select="concat(string-length($selected-value)+1,'ch')"/>;<xsl:text/>
					</xsl:attribute>
					<xsl:apply-templates mode="combobox:attributes" select="."/>
					<xsl:choose>
						<xsl:when test="$options[local-name()='nil' and namespace-uri()='http://www.w3.org/2001/XMLSchema-instance'] or not($options|$selected-value[not($options)])">
							<option class="data-row" value="" xo-scope="none">Sin opciones</option>
						</xsl:when>
						<xsl:when test="$options">
							<xsl:apply-templates mode="combobox:options-previous" select=".">
								<xsl:sort select="../@meta:text"/>
								<xsl:with-param name="selected-value" select="$selected-value"/>
								<xsl:with-param name="schema" select="$schema"/>
							</xsl:apply-templates>
							<optgroup class="filterable" label="Selecciona">
								<xsl:apply-templates mode="combobox:select-attributes" select="$options/ancestor::data:rows/@state:filter"/>
								<xsl:apply-templates mode="combobox:option" select="$options">
									<xsl:sort select="../@meta:text"/>
									<xsl:with-param name="selected-value" select="$selected-value"/>
									<xsl:with-param name="schema" select="$schema"/>
								</xsl:apply-templates>
							</optgroup>
							<xsl:apply-templates mode="combobox:options-following" select=".">
								<xsl:sort select="../@meta:text"/>
								<xsl:with-param name="selected-value" select="$selected-value"/>
								<xsl:with-param name="schema" select="$schema"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							-->
					<!--<xsl:attribute name="style">cursor:wait</xsl:attribute>-->
					<!--
							<xsl:apply-templates mode="combobox:option" select="$selected-value"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="$dataset/@meta:resultCount &gt; $dataset/@meta:pageSize">
						<option value="" xo-scope="none" class="disabled data-row">
							hay <xsl:value-of select="$dataset/@meta:resultCount - count($dataset/../data:rows/xo:r)"/> opciones más...
						</option>
					</xsl:if>-->
				</select>
			</ul>
			<script>
				<![CDATA[
xo.components.combobox = xo.components.combobox || {};

xo.components.combobox.focusin = function() {
	event.preventDefault(); event.stopPropagation(); 
    let srcElement = this;
	let opened_menus = [...document.querySelectorAll(`.combobox .dropdown-menu.show`)].filter(element => element.closest('.dropdown') != srcElement.closest('.dropdown'));
    for (let menu of opened_menus) {
		let dropdown = menu.closest('.dropdown')
        let toggler = dropdown && dropdown.querySelector("[data-bs-toggle]");
        if (toggler) {
            try {
                toggler = (bootstrap.Dropdown.getOrCreateInstance(toggler))
                toggler.hide();
            } catch (e) { }
        }
    }
}
xo.listener.on('focusin::.combobox [data-bs-toggle]:not(.show) [type=search],body', xo.components.combobox.focusin)

xo.listener.on('focusout', function(){
    this.justLostFocus   = true
    xo.delay(100).then(()=>{
    	delete this.justLostFocus
    })
})

xo.components.combobox.filter = function (event) {
    let self = this;
    let inputField = self;
	let searchText = (['focus','focusin'].includes(event.type) ? inputField.scope.value : inputField.value) || '';
    let dropdown = self.closest('.dropdown');
	let showDropdown = function() {
		let toggler = dropdown.querySelector("[data-bs-toggle]");
		if (toggler && !toggler.matches(".show")) {
			let focus_attr = self.getAttributeNode("onfocus");
			focus_attr && focus_attr.remove()
			toggler = (bootstrap.Dropdown.getOrCreateInstance(toggler))
			xo.listener.turnOff()
			xover.disablePolyfill["toString"] = true;
			toggler.show();
			xo.delay(100).then(()=>{
				delete xover.disablePolyfill["toString"];
			});
			xo.listener.on()
			focus_attr && self.setAttributeNode(focus_attr)
		}
	}
	if (event instanceof FocusEvent) {
		xo.delay(100).then(()=>{
			showDropdown()
		})
	} else {
		showDropdown()
	}
    let optionsList = self.ownerDocument.contains(self.optionsList) && self.optionsList || dropdown.querySelector('.dropdown-menu');
	//optionsList.ownerDocument.disconnect()
    self.optionsList = optionsList;

    let options = optionsList.querySelectorAll(".filterable li,.filterable option");
	optionsList.classList.remove("filtered");
    let option_group = optionsList.querySelector("optgroup");
	option_group && option_group.setAttribute("label", searchText && `Resultados para "${searchText}"` || "Selecciona")
	let filtered = false;
    for (let option of options) {
        if (!searchText || option.classList.contains("hint")) {
            option.classList.remove("hidden");
        } else if (option.classList.contains("disabled")) {
            option.classList.add("hidden");
			filtered = true
        } else if (option.textContent.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toLowerCase().includes(searchText.normalize('NFD').replace(/[\u0300-\u036f]|_|%/g, "").toLowerCase())) {
            option.classList.remove("hidden");
        } else {
			filtered = true
            option.classList.add("hidden");
        }
    }
	filtered && optionsList.classList.add("filtered");
}

xo.listener.on(`input::.combobox [type=search]`, xo.components.combobox.filter);
xo.listener.on('focusin::.combobox [data-bs-toggle]:not(.show) [type=search]', xo.components.combobox.filter);

xo.components.combobox.change = function () {
    let srcElement = event.srcElement;
    let dropdown = srcElement.closest('.dropdown');
	let selected_option = this.options[this.selectedIndex];
	let value = (selected_option  || document.createElement('p')).getAttributeNode("value");
	this.scope.set(value instanceof Attr ? value.value : selected_option.scope || select_option.value);
    let toggler = dropdown.querySelector("[data-bs-toggle]");
    try {
        if (toggler) {
            toggler = (bootstrap.Dropdown.getOrCreateInstance(toggler))
            toggler.hide();
        }
    } catch (e) { }
}

xo.components.combobox.keyup = function (event) {
    if ([' '].includes(event.key) && !event.ctrlKey) {
			event.preventDefault()
			event.stopImmediatePropagation();
	}
    if ((event.ctrlKey || event.altKey) || !['ArrowDown', 'ArrowUp', 'Escape', 'End', 'Home', 'PageDown', 'PageUp'].includes(event.key)) return;
    let self = event.srcElement;
    let dropdown = self.closest('.dropdown');
    let optionsList = self.optionsList || dropdown.querySelector('.dropdown-menu');
    self.optionsList = optionsList;

    filtered_options = optionsList.querySelectorAll("li, option").toArray().filter(option => !(option.style.display == 'none' || option.matches('.hidden')));

    if (event.key == 'Escape') {
        optionsList.classList.remove('show');
    } else {
        optionsList.classList.add('show');
    }
    let active_item = filtered_options.toArray().filter(option => option.selected || !option.disabled && !option.classList.contains("disabled") && option.classList.contains("active")).pop();
    let active_item_index = filtered_options.toArray().findIndex(option => option === active_item);
    if (event.key == 'ArrowDown') {
        ++active_item_index;
        active_item_index = active_item_index >= filtered_options.length ? filtered_options.length - 1 : active_item_index;
    } else if (event.key == 'ArrowUp') {
        --active_item_index;
        active_item_index = active_item_index < 0 ? 0 : active_item_index;
    } else if (event.key == 'Home') {
		active_item_index = 0
	} else if (event.key == 'End') {
		active_item_index = filtered_options.length - 1
	} else if (event.key == 'PageDown') {
        active_item_index += active_item.closest('select,ul').size || 10;
        active_item_index = active_item_index >= filtered_options.length ? filtered_options.length - 1 : active_item_index;
	} else if (event.key == 'PageUp') {
        active_item_index -= active_item.closest('select,ul').size || 10;
        active_item_index = active_item_index < 0 ? 0 : active_item_index;
	}
    active_item = filtered_options[active_item_index];
    [...filtered_options].forEach(op => op.classList.remove("active"));
    active_item && active_item.classList.add("active");
    if (active_item instanceof HTMLOptionElement) active_item.selected = true;
    //if (event.key=='Tab') {
    //	active_item && active_item.click();
    //	/*active_item && active_item.closest('.autocomplete-box').scope.set(active_item.classList.contains//("disabled")? "" : active_item.textContent)*/
    //	optionsList.classList.remove('show');
    //}
};
xo.listener.on('keyup::.combobox [type=search]', xo.components.combobox.keyup)

xo.components.combobox.keydown = function (event) {
    if (!['Tab', 'Enter'].includes(event.key)) return;
    let srcElement = event.srcElement;
    let dropdown = srcElement.closest('.dropdown');
    let scope = dropdown && dropdown.scope;
    let optionsList = dropdown && dropdown.querySelector('.dropdown-menu.show');
    if (!(optionsList && scope)) return;
    let toggler = dropdown.querySelector("[data-bs-toggle]");
    toggler && new bootstrap.Dropdown(toggler).hide();
    let input = dropdown.querySelector('input');
    let active_item = optionsList.querySelectorAll("li, option").toArray().filter(option => !(option.disabled || option.classList.contains("disabled")) && (option.selected || option.classList.contains("active"))).pop();
	value = (active_item  || document.createElement('p')).getAttributeNode("value");
    if (value) scope.set(value);
    if (input === input.ownerDocument.activeElement) input.blur();
}
xo.listener.on('keydown::.combobox [type=search]', xo.components.combobox.keydown)
xo.listener.on('keydown::button.combobox', function() {
	debugger
})

xo.listener.on('click::.dropdown li', function () {
    let active_item = this;
    active_item && active_item.closest('.autocomplete-box').scope.set(active_item.classList.contains("disabled") ? "" : active_item.textContent);
    optionsList.classList.remove('show');
})

xo.listener.on('hide.bs.dropdown', function() {
	if (this !== document.activeElement && this.contains(document.activeElement)) {
		event.preventDefault();
	}
})
		]]>
			</script>
		</div>
	</xsl:template>

	<xsl:template mode="combobox:attributes" match="@*|*"/>
	<xsl:template mode="combobox:option-attributes" match="@*|*"/>

	<xsl:template mode="combobox:option-value" match="*[@id]/@*">
		<xsl:value-of select="../@id"/>
	</xsl:template>

	<xsl:template mode="combobox:option-value" match="*[@key]/@*">
		<xsl:value-of select="../@key"/>
	</xsl:template>

	<xsl:template mode="combobox:display-text" match="@*">
		<xsl:param name="dataset" select="node-expected"/>
		<xsl:value-of select="$dataset[../@id=current() or ../@key=current()]"/>
	</xsl:template>

	<xsl:template mode="combobox:option-selected" match="*[@id or @key]/@*">
		<xsl:param name="selected-value" select="node-expected|current()"/>
		<xsl:if test="../@id = $selected-value or ../@key = $selected-value">
			<xsl:attribute name="selected"/>
		</xsl:if>
	</xsl:template>

	<xsl:template mode="combobox:option" match="@*|*">
		<xsl:param name="selected-value" select="node-expected|current()"/>
		<xsl:param name="schema" select="current()"/>
		<xsl:variable name="current" select="current()"/>
		<xsl:variable name="value">
			<xsl:apply-templates mode="combobox:option-value" select="."></xsl:apply-templates>
		</xsl:variable>
		<option class="data-row">
			<xsl:if test="$selected-value=$value">
				<xsl:attribute name="selected"/>
			</xsl:if>
			<xsl:if test="$value!=.">
				<xsl:attribute name="value">
					<xsl:value-of select="$value"/>
				</xsl:attribute>
			</xsl:if>
			<!--<xsl:apply-templates mode="combobox:option-selected" select="."/>-->
			<xsl:apply-templates mode="combobox:option-text" select="."/>
			<xsl:apply-templates mode="combobox:option-attributes" select="."/>
		</option>
	</xsl:template>

	<xsl:template mode="combobox:option-clear" match="@*">
		<option class="data-row" value="" style="color: red">- BORRAR SELECCIÓN -</option>
	</xsl:template>
</xsl:stylesheet>